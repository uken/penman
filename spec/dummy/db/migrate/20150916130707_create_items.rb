class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :reference
      t.integer :asset_id

      t.timestamps
    end
  end
end
