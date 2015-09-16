class CreateInventoryItems < ActiveRecord::Migration
  def change
    create_table :inventory_items do |t|
      t.integer :player_id
      t.integer :item_id

      t.timestamps
    end
  end
end
