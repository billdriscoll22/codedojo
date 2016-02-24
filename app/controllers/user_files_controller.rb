class UserFilesController < ApplicationController
  def all
    if params[:exerciseID].nil?
      render :json => {:error => "exerciseID is required"}, :status => 500
      return
    end

    exercise_id = Integer(params[:exerciseID])

    template_files = TemplateFile.where("exercise_id = ?", exercise_id)
    @result = []

    template_files.each do |template_file|
      if signed_in?
        Result.where(:user_id => current_user.id, :exercise_id => params[:exerciseID]).first_or_create(:is_correct => false)
        user_file = UserFile.where("file_name = ? and user_id = ? and exercise_id = ?", template_file.file_name, current_user.id, exercise_id)
        if user_file.exists?
          # file exists - return it to the user
          @result.push(user_file.first)
        else
          # file does not exist - copy it to user files
          new_file = UserFile.create do |f|
            f.content = template_file.content
            f.exercise_id = template_file.exercise_id
            f.file_name = template_file.file_name
            f.user_id = current_user.id
            f.should_compile = template_file.should_compile
          end
          @result.push(new_file)
        end
      else
        # not signed in - return only template files
        @result.push(TemplateFile.find(template_file.id))
      end
    end


    respond_to do |format|
      format.json { render json: @result }
    end
  end

  # GET /user_files
  # GET /user_files.json
  def index
    @user_files = UserFile.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_files }
    end
  end

  # GET /user_files/1
  # GET /user_files/1.json
  def show
    @user_file = UserFile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_file }
    end
  end

  # GET /user_files/new
  # GET /user_files/new.json
  def new
    @user_file = UserFile.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_file }
    end
  end

  # GET /user_files/1/edit
  def edit
    @user_file = UserFile.find(params[:id])
  end

  # POST /user_files
  # POST /user_files.json
  def create
    render :json => {:error => "access denied - cannot POST new user file"}, :status => 500
    return
  end

  # PUT /user_files/1
  # PUT /user_files/1.json
  def update
    @user_file = UserFile.find(params[:id])
    unless signed_in? and @user_file.user_id == current_user.id
      render :json => {:error => "access denied"}, :status => 500
      return
    end

    respond_to do |format|
      if @user_file.update_attributes(params[:user_file])
        format.html { redirect_to @user_file, notice: 'User file was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_files/1
  # DELETE /user_files/1.json
  def destroy
    @user_file = UserFile.find(params[:id])

    unless signed_in? and @user_file.user_id == current_user.id
      render :json => {:error => "access denied"}, :status => 500
      return
    end
    template_file = TemplateFile.where("file_name = ? and exercise_id = ?", @user_file.file_name, @user_file.exercise_id)
    @user_file.content = template_file.first.content
    @user_file.save

    respond_to do |format|
      format.html { redirect_to user_files_url }
      format.json { render json: @user_file }
    end
  end
end
