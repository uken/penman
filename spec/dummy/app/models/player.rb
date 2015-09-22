class Player < ActiveRecord::Base
  has_many :inventory_items
  has_many :items, through: :inventory_items

  def self.candidate_key
    :name
  end
end
