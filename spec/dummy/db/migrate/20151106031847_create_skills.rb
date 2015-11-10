class CreateSkills < ActiveRecord::Migration
  def change
    create_table :skills do |t|
      t.string :reference, unique: true
      t.timestamps null: false
    end
  end
end
