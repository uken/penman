$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'penman/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'penman'
  s.version     = Penman::VERSION
  s.authors     = ['Mat Pataki']
  s.email       = ['matpataki@gmail.com']
  s.homepage    = 'http://uken.com'
  s.summary     = 'Tracks database changes and generates representative seed files.'
  s.description = 'Penman will keep track of database changes on models that you mark as `Taggable`.'\
                  'Once the changes are ready to be propogated to other environments, a penman will generate a seed file '\
                  'representing those changes.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'rails', '~> 4'

  s.add_development_dependency 'mysql2', '~> 0.3', '>= 0.3.18'
  s.add_development_dependency 'rspec-rails', '~> 3.3', '>= 3.3.3'
  s.add_development_dependency 'pry-rails', '~> 0.3', '>= 0.3.4'
  s.add_development_dependency 'database_cleaner', '~> 1.5', '>= 1.5.1'
end
