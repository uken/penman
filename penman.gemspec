$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'penman/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'penman'
  s.version     = Penman::VERSION
  s.authors     = ['Mat Pataki']
  s.email       = ['matpataki@gmail.com']
  s.homepage    = 'https://github.com/uken/penman'
  s.summary     = 'Track realtime database changes and turn them into seed files.'
  s.description = "This project is a highly configurable rails engine that provides means to track database changes in realtime for models that you're interested in, when you're interested in them. Once recorded, Penman can produce seed / migration files that reflect these changes, allowing you to propagate them to other environments."
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'rails', '>= 4'

  s.add_development_dependency 'mysql2', '~> 0.3', '>= 0.3.18'
  s.add_development_dependency 'rspec-rails', '~> 3.3', '>= 3.3.3'
  s.add_development_dependency 'pry-rails', '~> 0.3', '>= 0.3.4'
  s.add_development_dependency 'database_cleaner', '~> 1.5', '>= 1.5.1'
end
