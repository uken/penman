module RecordTags
  class Configuration
    attr_accessor :seed_path

    def initialize
      @seed_path = 'db'
    end
  end
end
