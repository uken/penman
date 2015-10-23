module Penman
  class Configuration
    attr_accessor :seed_path
    attr_accessor :default_candidate_key
    attr_accessor :seed_method_name
    attr_accessor :seed_template_file

    def initialize
      @seed_path = 'db/migrate'
      @default_candidate_key = :reference
      @seed_method_name = :change

      root = File.expand_path '../..', __FILE__
      @seed_template_file = File.join(root, 'templates', 'default.rb.erb')
    end
  end
end
