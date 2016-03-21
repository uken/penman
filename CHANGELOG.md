### 0.0.6
- Removes the `Rails.env` check in the `Taggable` module.
  - This was a holdover from a previous project and shouldn't have been included here. We have `Penman.enable` and `Penman.disable` for this stuff.
- [Major change](https://github.com/uken/penman/commit/208f0c92d68a5496cb3bbe3e30abe2734e44580f)

### 0.1.6
- Adds support for custom seed file formatting via an `.erb.` file.
- `RecordTag` is now wrapped in the `Penman` module.
- `seed_method_name` config setting has been removed as the erb solution is better.
- add proper versioning
- [pull request](https://github.com/uken/penman/pull/1)

### 0.2.6
- Adds `Penman.enabled?`
- Adds configuration for the `file_name_formatter` method, allowing users to format their file names as they see fit.
- Removes `Penman.seed_path` and `Penman.default_candidate_key` as these can be easily accessed through `Penman.config.*`
- [pull request](https://github.com/uken/penman/pull/2)

### 0.2.7
- Fix bug for a case where a relation is defined between two models where the foreign key is not the primary key.
- Thanks to @jayvan for this fix.
- [pull request](https://github.com/uken/penman/pull/3)

### 0.2.8
- Adds back a check printed in the seeds files that allow the seeds to be safely run in environments where they were generated.
- [pull request](https://github.com/uken/penman/pull/4)

### 0.2.9
- Fix [issue 5](https://github.com/uken/penman/issues/5)
- Generate the seed order tree at seed generation time, not when the models are loaded. The issue was caused when the `include Taggable` line in the model was above any `belongs_to:` association. When the module is included the model is registered and ordered via a tree with RecordTags. If the `belongs_to` relation isn't setup yet, this ordering can be incorrect. By generating the seed order at seed generation time, we allow the models time to be fully setup before evaluating their relations.
- [pull request](https://github.com/uken/penman/pull/6)

### 0.3.9
- Adds the `after_generate` configurable callback that is to be used to add generated seeds to a migrations table of the user's choice.
- [pull request](https://github.com/uken/penman/pull/7)

### 0.4.9
- Adds an optional record validity check prior to seeds.
- [pull request](https://github.com/uken/penman/pull/9)

### 0.4.10
- Encode strings with `.inspect`, allowing for special characters in the strings to be escaped.
- [pull request](https://github.com/uken/penman/pull/10)

### 0.5.10
- relax rails constraint, allowing rails 5 apps to use the gem
- direct users to put the configuration in initializers
- [pull request](https://github.com/uken/penman/pull/11) (thanks @nearlyfreeapps)
