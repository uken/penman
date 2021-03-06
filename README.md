# Penman

This project is a highly configurable rails engine that provides means to track database changes in realtime for models that you're interested in, when you're interested in them. Once recorded, Penman can produce seed / migration files that reflect these changes, allowing you to propagate them to other environments.

In house at Uken, we use this gem enable our designers to add content to our games in their own environments. They can play, tweak, and iterate on content until they are happy with it, at which time they can push their desired changes down the pipe, eventually reaching our beloved players.

## A Quick Guide
Once the gem has been added to your gem file, run `rake db:migrate` to add Penman's `record_tags` table to your DB. This table is used to tag your DB records as they are changed.

Say you're interested in tracking changes to a your `Item` model. Include the `Taggable` module in your model:

```ruby
class Item < ActiveRecord::Base
  include Taggable

  # ...
end
```
By including the `Taggable` module, Penman will track changes to that module via Rails callbacks, and it's `RecordTag` model. However, it will only do this while enabled. Call `Penman.enable` / `Penman.disable` to globally turn on / off Penman tracking. This allows you to easily track changes only in certain contexts, for example, while executing admin panel logic.

Once satisfied with the changes made, call `Penman.generate_seeds` to produce seed files representing the changes. This method returns an array of seed file names which you can use to zip and download, upload elsewhere, commit directly to your repository, or to do with whatever else you'd like.

## Configuration
Here is an example config file that you should consider putting in a `config/initializers/penman.rb` file if the defaults aren't working for you:

```ruby
Penman.configure do |config|
  config.seed_path = 'some/path/where/seeds/should/go'
  config.default_candidate_key = [:some, :list, :of, :attributes]
  config.seed_template_file = 'my_seed_file_template.erb'
  config.validate_records_before_seed_generation = true
  config.file_name_formatter = lambda do |model_name, seed_type|
    "#{model_name}_#{seed_type}_seed"
  end
  config.after_generate = lambda do |version, name|
    # do some stuff with your new seed file
  end
end
```

#### seed_path
The `seed_path` option indicates where in the file system Penman should write the seed files, and defaults to `'db/migrate'`.

#### default_candidate_key
The `default_candidate_key` option is the candidate key used to identify records by default, and defaults to `:reference`. This can be configured on a model by model basis by adding a `candidate_key` class method. For example:
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

#### seed_template_file
The `seed_template_file` option is an erb file that allows you to customize the generated seed files. The default looks like this:
```ruby
# generated by penman

class <%= file_name.camelize %> < ActiveRecord::Migration
  def change
    <%= seed_code.print_with_leading_spaces(4) %>
  end
end
```
As you can see, some bindings are available to you in this file, namely the `file_name` and the `seed_code`. The `seed_code` is a simple wrapper that lets you print with a certain amount of leading spaces or tabs.

#### validate_records_before_seed_generation
This flag controls the calling of the [`validate!`](http://api.rubyonrails.org/classes/ActiveRecord/Validations.html#method-i-validate-21) method on each record tagged as updated or created that is to be seeded. If an invalid record is found, the `ActiveRecord::RecordInvalid` exception is raised, the seed is not be generated, and tags remain in-tact. This flag gets a default value of `false`.

#### file_name_formatter
The `file_name_formatter` option gives you a chance to customize the file name that the resulting seed file is given. It defaults to the following:
```ruby
lambda do |model_name, seed_type|
  "#{model_name.underscore.pluralize}_#{seed_type}"
end
```
`seed_type` will be one of `'updates'` (representing record creations or updates) or `'destroys'`. A time stamp will be added to the beginning of the seed file name. Aside from communicating when the seed was generated, it acts as an indicator of what order the seeds should be ran in. Rails will respect this time stamp by default, but if you're using another system to manage your seeds, you should make sure that it respects it as well, otherwise models that depend on one another (ex. models with `belongs_to` relations) may not seed correctly.

#### after_generate
The `after_generate` callback function is meant to give you the opportunity to add the seed to a schema migrations table of your choice. By default it looks for the standard `schema_migrations` table that rails uses, and adds it there if it can find it. If you use something custom, it would be best for you to implement this method to achieve this result.

Why is this important? For the most basic of use cases, it's not, however there are some edge cases that can get you in trouble if this method is not implemented. The seed files themselves account for their being run in the same environment that they were created, and in this case will produce no changes. This means that you can safely produce seed file `A`, and then run seed file `A` in the same environment without issue. However, if you were to produce seed file `A`, then seed file `B`, and they happen to be editing the same records, it is possible that when `A` runs, the changes made by `A` that are reflected in `B` will effect `A`'s result, which can be problematic. The simplest solution to this is to not run the seeds in the environment that they were created in, thus, the reason for the `after_generate` callback.

## Candidate Keys
A candidate key can be defined as a column or set of columns on a table that can uniquely identify each row. In most cases an `id` column alone accomplishes this task, however `id`s often vary between environments over time, a fact which demands we look to a different column or set of columns for this unique identification. It's worth taking this into consideration when architecting your models, as a table with only an `id` candidate key will not to play well with Penman, as it will have no reliable way of identifying rows across environments.

## Best Practices & Gotchas
Penman tracks changes via Rails callbacks, which means that the methods called to make changes need to fire them. Most common Rails methods do this, for example `create`, `update`, `destroy`, and their variants, to name a few, and some do not, for example `update_column` and `delete`. Note that this also means that changes made outside of Rails won't be tracked either.

When `Penman.generate_seeds` is called, the `record_tags` that were used to track the DB changes are destroyed in preparation for the next round of changes. This makes the generated seed files very precious, as they alone now represent the DB changes. Therefore, it is recommended that the logic you implement to handle the generated seed files be wrapped in a transaction. That way if something goes awry, the DB will be rolled back, reinstating the `record_tags`, preventing the loss of any work. Here's an example:

```ruby
require 'zip'

def download_seeds
  zip_file_name = "#{Rails.root}/db/#{Time.zone.now.strftime('%Y%m%d%H%M%S')}_seed_files.zip"

  ActiveRecord::Base.transaction do
    seed_files = Penman.generate_seeds
    Zip::File.open(zip_file_name, Zip::File::CREATE) do |zipfile|
      seed_files.each do |filename|
        file_path = filename.dup
        filename.slice!(filename =~ /#{Rails.root}/, "#{Rails.root}/".length)
        zipfile.add(filename, file_path)
      end
    end
  end

  send_file zip_file_name
end
```

## Constraints

Rails models and their relations can be setup in many different ways. Rather than trying to account for every possible setup, Penman imposes a simple constraint to simplify the problem that it solves. *Any relation between models tracked by Penman should use the associated model's `primary_key` as the foreign key in the relation.* By sticking to this rule, you will greatly reduce the chances of errors during your seed generation process. Using `id` is traditional, and works well. Similarly, if you change a model's primary key by assigning it in your model definition, then make sure that it's relations use the assigned primary key as well.
