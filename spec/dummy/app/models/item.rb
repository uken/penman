class Item < ActiveRecord::Base
  include Taggable

  belongs_to :asset
end
