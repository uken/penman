class CreateMultiSets < ActiveRecord::Migration
  def change
    create_table :multi_sets do |t|
      t.string :reference
      t.integer :weight
      t.integer :quantity

      t.timestamps
    end
  end
end
