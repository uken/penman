class AddPlayerInfoTable < ActiveRecord::Migration
  def change
    create_table :player_infos do |t|
      t.integer :player_id, null: false
      t.string :key, null: false
      t.string :value
    end
  end
end
