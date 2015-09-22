class CreateWeapons < ActiveRecord::Migration
  def change
    create_table :weapons do |t|
      t.string :reference
      t.integer :damage_factor, default: 1
      t.string :type
      t.boolean :ranged, default: true

      t.timestamps
    end

    add_index :weapons, :reference, unique: true
  end
end
