require 'active_record'
require 'penman/penman_exceptions'
require 'penman/seed_file_generator'
require 'penman/seed_code'

module Penman
  class RecordTag < ActiveRecord::Base
    belongs_to :record, polymorphic: true
    validates_uniqueness_of :tag, scope: [:record_type, :record_id]

    before_save :encode_candidate_key

    def encode_candidate_key
      if self.candidate_key.is_a? Hash
        self.candidate_key = self.candidate_key.to_json
      end
    end

    def decode_candidate_key(key)
      begin
        ActiveSupport::JSON.decode(key).symbolize_keys
      rescue JSON::ParserError
        # This will occur if the candidate key isn't encoded as json.
        #   An example of this would be when we are tagging yaml files as touched when messing with lang.
        #   In that case we store the file path in the candidate key column as a regular string.
        key
      end
    end

    @@enabled = false
    @@taggable_models = []

    def candidate_key
      decode_candidate_key(super)
    end

    class << self
      def disable
        @@enabled = false
      end

      def enable
        @@enabled = true
      end

      def enabled?
        @@enabled
      end

      def register(model)
        @@taggable_models |= [model]
      end

      def tag(record, tag)
        return unless @@enabled
        candidate_key = record.class.try(:candidate_key) || Penman.config.default_candidate_key
        candidate_key = [candidate_key] unless candidate_key.is_a? Array
        raise RecordTagExceptions::InvalidCandidateKeyForRecord unless record_has_attributes?(record, candidate_key)

        candidate_key_to_store =
          if ['created', 'destroyed'].include? tag
            Hash[candidate_key.map { |k| [k, record.send(k)] }].to_json
          else # updated
            Hash[candidate_key.map { |k| [k, record.send("#{k}_was")] }].to_json
          end

        created_tag = RecordTag.find_by(record: record, tag: 'created')
        updated_tag = RecordTag.find_by(record: record, tag: 'updated')
        destroyed_tag = RecordTag.find_by(record_type: record.class.name, candidate_key: candidate_key_to_store, tag: 'destroyed')

        raise RecordTagExceptions::TooManyTagsForRecord if [created_tag, updated_tag, destroyed_tag].count { |t| t.present? } > 1

        if created_tag.present?
          case tag
          when 'created'
            raise RecordTagExceptions::BadTracking, format_error_message('created', 'created', candidate_key_to_store)
          when 'updated'
            created_tag.update!(tag: tag)
          when 'destroyed'
            created_tag.destroy!
          end
        elsif updated_tag.present?
          case tag
          when 'created'
            raise RecordTagExceptions::BadTracking, format_error_message('updated', 'created', candidate_key_to_store)
          when 'updated'
            updated_tag.update!(tag: tag)
          when 'destroyed'
            if updated_tag.created_this_session
              updated_tag.destroy!
            else
              updated_tag.update!(tag: tag)
            end
          end
        elsif destroyed_tag.present?
          case tag
          when 'created'
            # We make an updated tag in case non-candidate key attributes have changed, since we don't tack those.
            destroyed_tag.update!(tag: 'updated', record_id: record.id)
          when 'updated'
            raise RecordTagExceptions::BadTracking, format_error_message('destroyed', 'updated', candidate_key_to_store)
          when 'destroyed'
            raise RecordTagExceptions::BadTracking, format_error_message('destroyed', 'destroyed', candidate_key_to_store)
          end
        else # new tag
          RecordTag.create!(record: record, tag: tag, candidate_key: candidate_key_to_store, created_this_session: tag == 'created')
        end
      end

      def find_tags_for_model(model)
        find_tags_for_models(model)
      end

      def find_tags_for_models(*models)
        RecordTag.where(record_type: models.map { |m| (m.is_a? String) ? m : m.name })
      end

      def create_custom(attributes = {})
        attributes = { record_type: 'custom_tag', tag: 'touched', candidate_key: 'n/a' }.merge attributes
        record_tag = RecordTag.find_or_create_by(attributes)
        record_tag.update(record_id: record_tag.id) if record_tag.record_id == 0 # notice validation above, this just ensures that we don't violate the table constraint.
      end

      def generate_seeds
        generate_seed_for_models(seed_order)
      end

      def generate_seed_for_models(models)
        time = Time.now
        seed_files = []

        models.each do |model|
          seed_files << generate_update_seed(model, time.strftime('%Y%m%d%H%M%S'))
          time += 1.second
        end

        models.reverse.each do |model|
          seed_files << generate_destroy_seed(model, time.strftime('%Y%m%d%H%M%S'))
          time += 1.second
        end

        RecordTag.where(record_type: models.map(&:name)).destroy_all
        seed_files.compact
      end

      def generate_seed_for_model(model)
        time = Time.now
        seed_files = []
        seed_files << generate_update_seed(model, time.strftime('%Y%m%d%H%M%S'))
        seed_files << generate_destroy_seed(model, (time + 1.second).strftime('%Y%m%d%H%M%S'))
        RecordTag.where(record_type: model.name).delete_all
        seed_files.compact
      end

      private
      def reset_tree
        @@roots       = []
        @@tree        = {}
        @@polymorphic = []
      end

      def add_model_to_tree(model)
        reflections = model.reflect_on_all_associations(:belongs_to)

        if reflections.find { |r| r.options[:polymorphic] }.present?
          @@polymorphic << model
        else
          @@roots.push(model) unless @@tree.key?(model)
        end

        @@tree[model] = reflections.reject { |r| r.options[:polymorphic] || r.klass == model }.map(&:klass)
        @@tree[model].each { |ch| @@tree[ch] ||= [] }

        @@roots -= @@tree[model]
      end

      def seed_order
        reset_tree
        @@taggable_models.each { |m| add_model_to_tree(m) }

        seed_order = []

        recurse_on = -> (node) do
          return unless node.ancestors.include?(Taggable)
          @@tree[node].each { |n| recurse_on.call(n) }
          seed_order |= [node]
        end

        @@roots.each { |node| recurse_on.call(node) }
        @@polymorphic.each { |node| recurse_on.call(node) }

        seed_order | @@polymorphic
      end

      def generate_update_seed(model, timestamp)
        validate_records_for_model(model) if Penman.config.validate_records_before_seed_generation
        touched_tags = RecordTag.where(record_type: model.name, tag: ['created', 'updated']).includes(:record)
        return nil if touched_tags.empty?
        seed_code = SeedCode.new
        seed_code << 'penman_initially_enabled = Penman.enabled?'
        seed_code << 'Penman.disable'

        touched_tags.each do |tag|
          seed_code << "# Generating seed for #{tag.tag.upcase} tag."
          seed_code << "record = #{model.name}.find_by(#{print_candidate_key(tag.record)})"
          seed_code << "record = #{model.name}.find_or_initialize_by(#{attribute_string_from_hash(model, tag.candidate_key)}) if record.nil?"

          column_hash = Hash[
            model.attribute_names
                 .reject { |col| col == model.primary_key }
                 .map { |col| [col, tag.record.send(col)] }
          ]

          seed_code << "record.update!(#{attribute_string_from_hash(model, column_hash)})"
        end

        seed_code << 'Penman.enable if penman_initially_enabled'
        seed_file_name = Penman.config.file_name_formatter.call(model.name, 'updates')
        sfg = SeedFileGenerator.new(seed_file_name, timestamp, seed_code)
        sfg.write_seed
      end

      def generate_destroy_seed(model, timestamp)
        destroyed_tags = RecordTag.where(record_type: model.name, tag: 'destroyed')
        return nil if destroyed_tags.empty?
        seed_code = SeedCode.new
        seed_code << 'penman_initially_enabled = Penman.enabled?'
        seed_code << 'Penman.disable'

        destroyed_tags.map(&:candidate_key).each do |record_candidate_key|
          seed_code << "record = #{model.name}.find_by(#{attribute_string_from_hash(model, record_candidate_key)})"
          seed_code << "record.try(:destroy)"
        end

        seed_code << 'Penman.enable if penman_initially_enabled'
        seed_file_name = Penman.config.file_name_formatter.call(model.name, 'destroys')
        sfg = SeedFileGenerator.new(seed_file_name, timestamp, seed_code)
        sfg.write_seed
      end

      def validate_records_for_model(model)
        RecordTag.where(record_type: model.name, tag: ['updated', 'created'])
                 .includes(:record)
                 .each { |r| r.record.validate! }
      end

      def print_candidate_key(record)
        candidate_key = record.class.try(:candidate_key) || Penman.config.default_candidate_key
        candidate_key = [candidate_key] unless candidate_key.is_a? Array
        raise RecordTagExceptions::InvalidCandidateKeyForRecord unless record_has_attributes?(record, candidate_key)

        candidate_key_hash = {}
        candidate_key.each { |key| candidate_key_hash[key] = record.send(key) }
        attribute_string_from_hash(record.class, candidate_key_hash)
      end

      def attribute_string_from_hash(model, column_hash)
        column_hash.symbolize_keys!
        formatted_candidate_key = []

        column_hash.each do |k, v|
          reflection = find_foreign_key_relation(model, k)

          if reflection && v.present?
            associated_model = if reflection.polymorphic?
              column_hash[reflection.foreign_type.to_sym].constantize
            else
              reflection.klass
            end

            if associated_model.ancestors.include?(Taggable) || associated_model.respond_to?(:candidate_key)
              primary_key = reflection.options[:primary_key] || associated_model.primary_key
              associated_record = associated_model.find_by(primary_key => v)
              to_add = "#{reflection.name}: #{associated_model.name}.find_by("

              if associated_record.present?
                to_add += "#{print_candidate_key(associated_record)})"
              else # likely this record was destroyed, so we should have a tag for it
                tag = RecordTag.find_by(record_type: associated_model.name, record_id: v)
                raise RecordTagExceptions::RecordNotFound, "while processing #{column_hash}" if tag.nil?
                to_add += "#{attribute_string_from_hash(associated_model, tag.candidate_key)})"
              end

              formatted_candidate_key << to_add
              next
            end
          end

          formatted_candidate_key << "#{k}: #{primitive_string(v)}"
        end

        formatted_candidate_key.join(', ')
      end

      def find_foreign_key_relation(model, accessor)
        model.reflect_on_all_associations.find do |r|
          begin
            r.foreign_key.to_sym == accessor.to_sym
          rescue NameError
            false
          end
        end
      end

      def record_has_attributes?(record, attributes)
        attributes.each do |attribute|
          return false unless record.has_attribute?(attribute)
        end

        true
      end

      def primitive_string(p)
        if p.nil?
          'nil'
        elsif p.is_a? String
          p.inspect
        elsif p.is_a? Time
          "Time.parse('#{p}')"
        else
          "#{p}"
        end
      end

      def format_error_message(existing_tag, new_tag, record_to_store)
        "found an existing '#{existing_tag}' tag for record while tagging, '#{new_tag}' - #{record_to_store}"
      end
    end
  end
end
