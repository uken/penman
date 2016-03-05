Penman.configure do |config|
  config.seed_path = File.join(Rails.root, 'db', 'migrate')
  config.default_candidate_key = :reference
  config.validate_records_before_seed_generation = true
end
