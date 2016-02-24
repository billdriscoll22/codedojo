class UserFile < ActiveRecord::Base
  attr_accessible :content, :exercise_id, :file_name, :user_id, :should_compile
	validates :file_name, :exercise_id, :content, :user_id, :presence => true
  belongs_to :exercise
  belongs_to :user
end
