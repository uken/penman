module RecordTags
  class Configuration
    attr_accessor :seed_path
    attr_accessor :default_candidate_key

    def initialize
      @seed_path = 'db'
      @default_candidate_key = :reference
    end
  end
end
