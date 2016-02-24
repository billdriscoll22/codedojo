class Tutorial < ActiveRecord::Base
  attr_accessible :description, :difficulty, :num_ratings, :rating, :title, :user_id, :category_id, :sections_attributes
  validates :num_ratings, :description, :title, :difficulty, :rating, :user_id, :category_id, :presence => true
  has_many :sections, :dependent => :delete_all
  has_and_belongs_to_many :tags
  belongs_to :category
  belongs_to :user
  has_many :ratings, :dependent => :delete_all
  has_many :exercises, :through => :sections, :dependent => :destroy
  accepts_nested_attributes_for :sections
  after_initialize :default_values
  
  #sets required attributes to a default value if they are not set yet
  def default_values
    self.num_ratings ||=0
    self.rating ||=0
    self.category_id ||=1
    self.user_id ||=1
  end
end
