class InventoryItem < ActiveRecord::Base
  belongs_to :item
  belongs_to :player
end
