require 'record_tags/configuration'
# require 'record_tags/record_tag'

module RecordTags
  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.seed_path
    @configuration.seed_path
  end
end
