require "penman/engine"
require 'penman/configuration'
require 'penman/record_tag'
require 'penman/taggable'

module Penman
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

  def self.enable
    RecordTag.enable
  end

  def self.disable
    RecordTag.disable
  end

  def self.generate_seeds
    RecordTag.generate_seeds
  end
end
