module RecordTagExceptions
  RecordTagError = Class.new(StandardError)

  InvalidCandidateKeyForRecord = Class.new(RecordTagError)
  RecordNotFound = Class.new(RecordTagError)
  TooManyTagsForRecord = Class.new(RecordTagError)
  BadTracking = Class.new(RecordTagError)
end
