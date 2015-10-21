module Penman
  class Configuration
    attr_accessor :seed_path
    attr_accessor :default_candidate_key
    attr_accessor :seed_method_name

    def initialize
      @seed_path = 'db/migrate'
      @default_candidate_key = :reference
      @seed_method_name = :change
    end
  end
end
