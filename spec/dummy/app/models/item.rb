class Item < ActiveRecord::Base
  include Taggable
  validates :reference, presence: true

  belongs_to :asset
end
