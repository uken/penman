class Stage < ActiveRecord::Base
  self.primary_key = 'reference'

  include Taggable
end
