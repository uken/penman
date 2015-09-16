class MultiSetMember < ActiveRecord::Base
  belongs_to :multi_set
  belongs_to :setable, polymorphic: true
end
