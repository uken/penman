class CreateStages < ActiveRecord::Migration
  def change
    create_table :stages do |t|
      t.string :reference, null: false
      t.integer :order
    end

    add_index :stages, :reference, unique: true
  end
end
