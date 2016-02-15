module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :record_tags

    after_create  { Penman::RecordTag.tag(self, 'created') }
    after_update  { Penman::RecordTag.tag(self, 'updated') }
    after_destroy { Penman::RecordTag.tag(self, 'destroyed') }

    Penman::RecordTag.register(self)
  end
end
