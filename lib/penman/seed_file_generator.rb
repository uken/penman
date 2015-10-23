module Penman
  class SeedFileGenerator
    attr_reader :seed_code
    attr_reader :timestamp

    def initialize(seed_code, timestamp)
      @seed_code = seed_code
      @timestamp = timestamp
    end

    def write_seed
      erb = ERB.new(File.read('guy_template.erb')) # TODO change this to a config setting
      result = erb.result(binding)
    end
  end
end
