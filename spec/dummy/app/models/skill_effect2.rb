class SkillEffect2 < ActiveRecord::Base
  include Taggable # for testing that seed order is not effected by where you include taggable
  belongs_to :skill, foreign_key: 'skill_reference', primary_key: 'reference'
end
