require "penman/engine"
require 'penman/configuration'
require 'penman/record_tag'
require 'penman/taggable'
require 'penman/seed_file_generator'

module Penman
  class << self
    attr_writer :config

    def config
      @config ||= Configuration.new
    end

    def configure
      yield(config)
    end

    def reset
      @config = Configuration.new
    end

    def enable
      RecordTag.enable
    end

    def disable
      RecordTag.disable
    end

    def enabled?
      RecordTag.enabled?
    end

    def generate_seeds
      RecordTag.generate_seeds
    end

    def dependent_records_for(record)
      return [] unless record.respond_to?(:record_tag) && record.record_tag.present?
      record.record_tag.dependent_tags.map(&:record)
    end
  end
end
