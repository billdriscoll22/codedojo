class User < ActiveRecord::Base
	attr_accessible :password_digest, :salt, :username
	validates :username, :password_digest, :salt, :presence => true
	validates :username, :uniqueness => true
	has_many :results, :dependent => :delete_all
	has_many :tutorials, :dependent => :delete_all
	has_many :files, :dependent => :delete_all
	has_many :followers, :class_name => 'Followings', :foreign_key => 'user_id'
	has_many :following, :class_name => 'Followings', :foreign_key => 'follower_id'
	has_many :ratings, :dependent => :delete_all

	def password_valid?(candidatePassword)
		passwordAndSalt = candidatePassword + self.salt
		digest = Digest::SHA1.hexdigest(passwordAndSalt)
		if(digest == self.password)
			return true
		else
			return false
		end
	end

	def password=(rawPassword)
		salt = rand.to_s
		self.salt = salt
		self.password_digest = Digest::SHA1.hexdigest(rawPassword + salt)
	end

	def password
		return self.password_digest
	end

	def isFollowing?(followedId)
		return self.following.where(:user_id => followedId).length > 0
	end

	def getSenseiFeed(limit)
		followings = self.following
		newTutorials = []
		followings.each do |following|
			sensei = User.find_by_id(following.user_id)
			tut = Tutorial.where(:user_id => sensei.id)
			tut.each do |t|
				newTutorials.push(t)
			end
		end
		newTutorials.sort!{|a, b| a.created_at <=> b.created_at}
		messageArray = []
		counter = 0
		newTutorials.each do |t|
			if(counter == limit)
				break
			end
			creator = User.find_by_id(t.user_id)
			messageObj = {}
			messageObj["creator_name"] = creator.username
			messageObj["creator_id"] = creator.id
			messageObj["creator"] = creator
			messageObj["tutorial_title"] = t.title
			messageObj["tutorial_id"] = t.id
			messageArray.push(messageObj)
			counter += 1
		end
		return messageArray
	end

	def loggedIn?(session)
		return(self.id.to_s == session[:id].to_s)
	end

	def self.getAllNames
		returnArray = []
		find(:all).each do |u|
			returnArray.push(u.username)
		end
		return returnArray
	end

	def getNumTutorialsTaken
		tutorialSet = Set.new
		self.results.each do |result|
      exercise = Exercise.find_by_id(result.exercise_id)
      if exercise != nil
        section = Section.find_by_id(exercise.section_id)
        if section != nil
          tutorialSet.add(section.tutorial_id)
        end
      end
		end
		return tutorialSet.size
	end

	def getTypeTutorialsTaken
		difficulties = [0]
		correctResults = self.results.where(:is_correct => true)
		correctResults.each do |result|
			difficulties.push(Tutorial.find_by_id(Section.find_by_id(Exercise.find_by_id(result.exercise_id).section_id).tutorial_id).difficulty)
		end
		return most_common_value(difficulties)
	end

	def most_common_value(a)
  		a.group_by do |e|
    		e
  		end.values.max_by(&:size).first
	end

	def get_avg_rating
		ratings = []
		self.tutorials.each do |tutorial|
			tutorial.ratings.each do |rating|
				ratings.push(rating.score)
			end
		end
		if(ratings.length > 0)
			return((ratings.sum)/(ratings.length.to_f))
		else
			return("N/A")
		end
	end

end
