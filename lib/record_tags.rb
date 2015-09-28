require "record_tags/engine"
require 'record_tags/configuration'
require 'record_tags/record_tag'
require 'record_tags/taggable'

module RecordTags
  class << self
    attr_writer :config
  end

  def self.configuration
    @config ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.reset
    @config = Configuration.new
  end

  def self.seed_path
    configuration.seed_path
  end

  def self.default_candidate_key
    configuration.default_candidate_key
  end
end
