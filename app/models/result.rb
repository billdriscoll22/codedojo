class Result < ActiveRecord::Base
  attr_accessible :exercise_id, :is_correct, :user_id
	validates :user_id, :exercise_id, :presence => true
	validates :is_correct, :inclusion => { :in => [true, false] }
  belongs_to :user
  belongs_to :exercise
end
