class Rating < ActiveRecord::Base
  attr_accessible :score, :tutorial_id, :user_id
	validates :score, :tutorial_id, :user_id, :presence => true
	belongs_to :user
	belongs_to :tutorial
end
