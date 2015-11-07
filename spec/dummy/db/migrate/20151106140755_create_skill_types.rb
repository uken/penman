class CreateSkillTypes < ActiveRecord::Migration
  def change
    create_table :skill_types do |t|
      t.string :reference, unique: true
      t.timestamps null: false
    end
  end
end
