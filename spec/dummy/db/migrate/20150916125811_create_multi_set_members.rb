class CreateMultiSetMembers < ActiveRecord::Migration
  def change
    create_table :multi_set_members do |t|
      t.integer :multi_set_id
      t.string :setable_type
      t.integer :setable_id
      t.integer :weight, default: 1
      t.integer :quantity, default: 1

      t.timestamps
    end
  end
end
