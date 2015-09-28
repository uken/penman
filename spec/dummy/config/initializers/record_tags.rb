RecordTags.configure do |config|
  config.seed_path = File.join(Rails.root, 'db', 'migrate')
  config.default_candidate_key = :name
end
