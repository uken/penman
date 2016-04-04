class PlayerInfo < ActiveRecord::Base
  belongs_to :user

  # notice that this doesn't include Taggable.
end
