class UsersController < ApplicationController
  include ApplicationHelper
  require 'pygmentize'
  # GET /users
  # GET /users.json
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  def login
    userName = params[:user][:username]
    user = User.find_by_username(userName)
    if(user == nil)
      flash[:positivity] = "negative"
      flash[:notice] = "Username not found.  Please enter a valid username."
      redirect_to(:root)
    else
      if(user.password_valid?(params[:user][:password]))
        reset_session
        session[:id] = user.id
        redirect_to(user, :id => user.id)
      else
        flash[:notice] = "Incorrect Password"
        redirect_to(:root)
      end
    end
  end

  def logout
      reset_session
      redirect_to(:root)
  end

  # GET /users/1
  # GET /users/1.json
  def show
    id = params[:id]
    @homeScreen = false
    @user = User.find(params[:id])
    file = UserFile.order("updated_at desc").where(:user_id => id).limit(1)
    @hasExercise = false
    if(file.length > 0)
      file = file[0]
      @fileContent = file.content
      @exercise_id = file.exercise_id
      @lastExercise = Exercise.find_by_id(@exercise_id)
      @lastSection = Section.find_by_id(@lastExercise.section_id)
      @lastTutorial = Tutorial.find_by_id(@lastSection.tutorial_id)
      @hasExercise = true
    end
    @senseiTutorials = Tutorial.order("created_at desc").where(:user_id => id).limit(5)
    if(@user.loggedIn?(session))

      @newTutorials1 = Tutorial.order("created_at desc").limit(3)
      @newSenseis = []
      @newTutorials1.each do |t|
        @newSenseis.push(User.find_by_id(t.user_id))
      end
      logger.debug("_+_+")
      logger.debug(@newSenseis)
      @senseiFeed = @user.getSenseiFeed(10)
      @homeScreen = true
      @popularTutorials = Tutorial.order("num_ratings desc").limit(10)
      @newTutorials = Tutorial.order("created_at desc").limit(10)
      @allNames = User.getAllNames
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @user }
      end
    else
      if signed_in?
        @isFollowing = current_user.isFollowing?(params[:id])
      else
        @isFollowing = false
      end
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    if(params[:user][:password] != params[:user][:password_repeat])
      flash[:notice] = "Passwords didn't match!"
      redirect_to(:root)
      #redirect_to(:action => :register)
    elsif(params[:user][:password] == "")
      flash[:notice] = "Password cannot be blank"
      redirect_to(:root)
    else
      @user = User.new
      @user.username = params[:user][:username]
      @user.password=(params[:user][:password])
      @user.email = params[:user][:email]
      if(@user.valid?)
        @user.save
        session[:id] = @user.id
        redirect_to(@user, :id => @user.id)
        #flash[:notice] = "You have successfully registered and can now log in."
        #redirect_to(:action => :login)
      else
        flash[:notice] = "Username in use"
        redirect_to(:root)
      end
    end
  end

  def follow
      @followed = User.find_by_username(params[:username])
      @user = User.find_by_id(session[:id])
      if(!@followed)
        flash[:positivity] = "negative"
        flash[:notice] = "No user with that username exists"
        redirect_to(@user, :id => session[:id])
      elsif(Followings.where(:follower_id => @user.id, :user_id => @followed.id).size > 0)
        flash[:positivity] = "negative"
        flash[:notice] = "You already following this user"
        redirect_to(@user, :id => session[:id])
      
      elsif(@followed.id == @user.id)
        flash[:positivity] = "negative"
        flash[:notice] = "You can't follow yourself."
        redirect_to(@user, :id => session[:id])
      else
        Followings.new(:follower_id => session[:id], :user_id => @followed.id).save(:validate => true)
        flash[:positivity] = "positive"
        flash[:notice] = @followed.username + " is now your sensei.  You will get updates on their tutorial creation activity."
        redirect_to(@user, :id => session[:id])
      end

  end

  def unfollow
    @user = User.find_by_id(session[:id])
    Followings.where(:user_id => User.find_by_username(params[:username]).id, :follower_id => session[:id]).destroy_all
    flash[:positivity] = "positive"
    flash[:notice] = "You have stopped following this user"
    redirect_to(@user, :id => session[:id])
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  def difficulty(index)
    case index
    when 0
      return '<span class="label label-info">Beginner</span>'.html_safe
    when 1
      return '<span class="label label-success">Advanced Beginner</span>'.html_safe
    when 2
      return '<span class="label label-warning">Competent</span>'.html_safe
    when 3
      return '<span class="label label-important">Proficient</span>'.html_safe
    when 4
      return '<span class="label label-inverse">Expert</span>'.html_safe
    end
  end

  def pyg(code, lang)
    if(lang == "c++")
      lang = "cpp"
    end
    return(Pygmentize.process(code, lang))
  end
  
end
