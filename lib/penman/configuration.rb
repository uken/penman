module Penman
  class Configuration
    attr_accessor :seed_path
    attr_accessor :default_candidate_key
    attr_accessor :seed_template_file
    attr_accessor :file_name_formatter

    def initialize
      @seed_path = 'db/migrate'
      @default_candidate_key = :reference

      root = File.expand_path '../..', __FILE__
      @seed_template_file = File.join(root, 'templates', 'default.rb.erb')

      @file_name_formatter = lambda do |model_name, seed_type|
        "#{model_name.underscore.pluralize}_#{seed_type}"
      end
    end
  end
end
