class AddSkillTypeToSkill < ActiveRecord::Migration
  def change
    add_column :skills, :skill_type_id, :integer
  end
end
