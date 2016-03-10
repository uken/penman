module Penman
  class Configuration
    attr_accessor :seed_path,
                  :default_candidate_key,
                  :seed_template_file,
                  :file_name_formatter,
                  :after_generate,
                  :validate_records_before_seed_generation

    def initialize
      @seed_path = 'db/migrate'
      @default_candidate_key = :reference

      root = File.expand_path '../..', __FILE__
      @seed_template_file = File.join(root, 'templates', 'default.rb.erb')

      @file_name_formatter = lambda do |model_name, seed_type|
        "#{model_name.underscore.pluralize}_#{seed_type}"
      end

      @after_generate = lambda do |version, name|
        return unless ActiveRecord::Base.connection.table_exists? 'schema_migrations'

        unless Object.const_defined?('SchemaMigration')
          Object.const_set('SchemaMigration', Class.new(ActiveRecord::Base))
        end

        return unless SchemaMigration.column_names.include? 'version'

        SchemaMigration.find_or_create_by(version: version)
      end

      @validate_records_before_seed_generation = false
    end
  end
end
