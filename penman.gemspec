$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "penman/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "penman"
  s.version     = Penman::VERSION
  s.authors     = ["Mat Pataki"]
  s.email       = ["matpataki@gmail.com"]
  # s.homepage    = "TODO"
  s.summary     = "Summary of Penman."
  s.description = "Description of Penman."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 4"

  s.add_development_dependency "mysql2"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency 'pry-rails'
  s.add_development_dependency 'database_cleaner'
end
