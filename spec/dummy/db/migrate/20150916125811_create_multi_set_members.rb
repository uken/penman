class CreateMultiSetMembers < ActiveRecord::Migration
  def change
    create_table :multi_set_members do |t|
      t.integer :multi_set_id
      t.string :setable_type
      t.integer :setable_id
      t.integer :weight
      t.integer :quantity

      t.timestamps
    end
  end
end
