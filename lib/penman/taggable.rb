module Taggable
  extend ActiveSupport::Concern

  included do
    unless Rails.env.staging? || Rails.env.production?
      has_many :record_tags, as: :record

      after_create  { RecordTag.tag(self, 'created') }
      after_update  { RecordTag.tag(self, 'updated') }
      after_destroy { RecordTag.tag(self, 'destroyed') }

      RecordTag.register(self)
    end
  end
end
