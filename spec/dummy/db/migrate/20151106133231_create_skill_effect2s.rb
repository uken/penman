class CreateSkillEffect2s < ActiveRecord::Migration
  def change
    create_table :skill_effect2s do |t|
      t.string :reference, unique: true
      t.string :skill_reference

      t.timestamps null: false
    end
  end
end
