class TestFile < ActiveRecord::Base
  attr_accessible :content, :exercise_id, :file_name
	validates :file_name, :content, :presence => true
  belongs_to :exercise
end
