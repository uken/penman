class Skill < ActiveRecord::Base
  has_many :skill_effects, foreign_key: 'skill_reference', primary_key: 'reference'
  belongs_to :skill_type
  include Taggable
end
