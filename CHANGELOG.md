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
