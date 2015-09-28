class MultiSetMember < ActiveRecord::Base
  include Taggable

  belongs_to :multi_set
  belongs_to :setable, polymorphic: true

  def self.candidate_key
    [:multi_set_id, :setable_type, :setable_id, :quantity]
  end
end
