require "penman/engine"
require 'penman/configuration'
require 'penman/record_tag'
require 'penman/taggable'
require 'penman/seed_file_generator'

module Penman
  class << self
    attr_writer :config
  end

  def self.config
    @config ||= Configuration.new
  end

  def self.configure
    yield(config)
  end

  def self.reset
    @config = Configuration.new
  end

  def self.enable
    RecordTag.enable
  end

  def self.disable
    RecordTag.disable
  end

  def self.enabled?
    RecordTag.enabled?
  end

  def self.generate_seeds
    RecordTag.generate_seeds
  end
end
