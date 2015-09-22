class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets do |t|
      t.string :reference

      t.timestamps
    end

    add_index :assets, :reference, unique: true
  end
end
