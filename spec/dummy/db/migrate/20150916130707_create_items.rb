class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :reference
      t.integer :asset_id

      t.timestamps
    end

    add_index :items, :reference, unique: true
  end
end
