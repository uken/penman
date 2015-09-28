$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "record_tags/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "record_tags"
  s.version     = RecordTags::VERSION
  s.authors     = ["Mat Pataki"]
  s.email       = ["matpataki@gmail.com"]
  # s.homepage    = "TODO"
  s.summary     = "Summary of RecordTags."
  s.description = "Description of RecordTags."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.12"

  s.add_development_dependency "mysql2"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency 'pry-rails'
end
