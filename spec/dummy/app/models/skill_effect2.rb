class SkillEffect2 < ActiveRecord::Base
  belongs_to :skill, foreign_key: 'skill_reference', primary_key: 'reference'
  include Taggable # for testing that seed order is not effected by where you include taggable
end
