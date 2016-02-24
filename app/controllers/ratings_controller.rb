class RatingsController < ApplicationController
  # GET /ratings
  # GET /ratings.json
  def index
    @ratings = Rating.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @ratings }
    end
  end

  # GET /ratings/1
  # GET /ratings/1.json
  def show
    @rating = Rating.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @rating }
    end
  end

  # GET /ratings/new
  # GET /ratings/new.json
  def new
    @rating = Rating.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @rating }
    end
  end

  # GET /ratings/1/edit
  def edit
    @rating = Rating.find(params[:id])
  end

  # POST /ratings
  # POST /ratings.json
  def create
    @rating = Rating.new(params[:rating])

    respond_to do |format|
      if @rating.save
        format.html { redirect_to @rating, notice: 'Rating was successfully created.' }
        format.json { render json: @rating, status: :created, location: @rating }
      else
        format.html { render action: "new" }
        format.json { render json: @rating.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /ratings/1
  # PUT /ratings/1.json
  def update
    @rating = Rating.find(params[:id])

    respond_to do |format|
      if @rating.update_attributes(params[:rating])
        format.html { redirect_to @rating, notice: 'Rating was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @rating.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ratings/1
  # DELETE /ratings/1.json
  def destroy
    @rating = Rating.find(params[:id])
    @rating.destroy

    respond_to do |format|
      format.html { redirect_to ratings_url }
      format.json { head :no_content }
    end
  end

	def merge_rating
		rating = params[:rating].to_i
		userID = params[:userID].to_i
		tutorialID = params[:tutorialID].to_i
		user_rating = Rating.where(:user_id => userID, :tutorial_id => tutorialID).first
		exists = true
		if user_rating.nil?
			exists = false
			user_rating = Rating.new(:user_id => userID, :tutorial_id => tutorialID, :score => rating)
		end
		tutorial = Tutorial.find(tutorialID)
		current_score = tutorial.rating
		num_ratings = tutorial.num_ratings
		current_score *= num_ratings
		if exists
			current_score -= user_rating.score
			user_rating.score = rating
		else
			num_ratings += 1
		end
		current_score += rating
		current_score /= num_ratings
		tutorial.num_ratings = num_ratings
		tutorial.rating = current_score
		tutorial.save
		user_rating.save

		respond_to do |format|
			format.js { render :text => current_score }
		end
	end

end
