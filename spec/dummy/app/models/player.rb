class Player < ActiveRecord::Base
  has_many :inventory_items
  has_many :items, through: :inventory_items
end
