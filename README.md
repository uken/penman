# Penman
A scribe for your database and Rails project, Penman records your DB changes and produces seed files that reflect them.

### A Quick Guide
Once the gem has been added to your gem file, rune `rake db:migrate` to add Penman's `record_tags` table to your db. This table is used to tag your DB records as they are changed. Now, to the good stuff...

Say you're interested in tracking changes to a your `Item` model. Include the `Taggable` module in your model:

```ruby
class Item < ActiveRecord::Base
  include Taggable

  # ...
end
```
By including the `Taggable` module, Penman will track changes to that module via Rails callbacks, and it's `RecordTag` model. However, it will only do this while enabled. Call `Penman.enable` / `Penman.disable` to globally turn on / off Penman tracking. This allows you to easily track changes only in certain contexts, for example, while executing admin panel logic.

Once satisfied with the changes made, call `Penman.generate_seeds` to produce seed files representing the changes. This method returns an array of seed file names which you can use to zip and download, upload elsewhere, commit directly to your repository, etc.

### Configuration
Here is an example config file that you should consider putting in a `config/penman.rb` file:

```ruby
Penman.configure do |config|
  config.seed_path = 'some/path/where/seeds/should/go'
  config.default_candidate_key = [:some, :list, :of, :attributes]
end
```

The `seed_path` option above indicates where in the file system Penman should write the seed files, and defaults to `'db/migrate'`.

The `default_candidate_key` option is the candidate key used to identify a records by default, and defaults to `:reference`. This can be configured on a model by model basis by adding a `candidate_key` class method to your models. For example:
```ruby
class Player < ActiveRecord::Base
  include Taggable

  # ...

  def self.candidate_key
    :name
  end
end
```
This method can also return an array of attributes.

### Candidate Keys
A candidate key can be defined as a column or set of columns on a table that can uniquely identify each row. Note that in most cases an `id` column alone accomplishes this task, however `id`s can vary between environments over time, a fact which demands we look to a different column or set of columns for this unique identification. It's worth taking this into consideration when architecting your models, as a table without only an `id` candidate key is likely not to play well with Penman.

### Gotchas!
Penman tracks changes via Rails callbacks, which means that the methods called to make changes need to fire them. Most common Rails methods do this, for example `create`, `update`, `destroy`, and their variants, to name a few, and some do not, for example `update_column` and `delete`. Note that this also means that changes made outside of Rails won't be tracked either.
