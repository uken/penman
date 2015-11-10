class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets do |t|
      t.string :reference, unique: true

      t.timestamps
    end

    add_index :assets, :reference, unique: true
  end
end
