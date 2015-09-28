class MultiSet < ActiveRecord::Base
  include Taggable

  has_many :multi_set_members
end
