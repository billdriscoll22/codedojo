class OutputValidator < ActiveRecord::Base
  attr_accessible :args, :exercise_id, :validator
  validates :validator, :presence => true
  belongs_to :exercise
end
