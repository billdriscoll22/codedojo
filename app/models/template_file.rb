class TemplateFile < ActiveRecord::Base
  attr_accessible :content, :exercise_id, :file_name, :should_compile
	validates :file_name, :presence => true
  belongs_to :exercise
end
