class TutorialsController < ApplicationController
  # GET /tutorials
  # GET /tutorials.json
  def index
    session[:currTags] = [];
    @tutorials = Tutorial.find(:all, :order => "rating DESC, updated_at")
    @tutorialViewBoxes = tutorialViewBox_factory(@tutorials)
    @tags = Tag.find(:all, :select => "name").map(&:name)
    @categories = Category.all
    respond_to do |format|
      format.html{render :layout => 'application_no_footer'} 
      format.json { render json: @tutorialViewBoxes }
    end
  end

  # GET /tutorials/1
  # GET /tutorials/1.json
  def show
    @tutorial = Tutorial.find(params[:id])
    @tutorialView = tutorialViewBox_factory([@tutorial])[0]
    @sectionViewBoxes = []
    status = ""
		@tutorial.sections.order("index").each do |section|
      resultHash = Hash.new
      exercises_completed=0
      if signed_in?
        is_complete = true
        is_attempted = false
        exerciseIds = []
        section.exercises.each do |exercise|
          exerciseIds << exercise.id
        end
        results = Result.where(:exercise_id => exerciseIds, :user_id => current_user.id)
        num_results = results.size
        num_correct = 0

        results.each do |result|
          resultHash[result.exercise_id] = result[:is_correct]
          if result[:is_correct]
            num_correct += 1
          end
        end
        exercises_completed = num_correct
        if num_results > 0
          is_attempted = true
        end
        if num_correct < exerciseIds.size
          is_complete = false
        end
        status = "Not Attempted"
        if is_attempted
          status = "In Progress"
        end
        if is_complete
          status = "Complete"
        end
        percentage=exercises_completed.to_f/section.exercises.length*100
        @sectionViewBoxes << { :section => section, :status => status, :results => resultHash,:num_exercises_completed=>exercises_completed,:num_exercises=>section.exercises.length,:percent_complete=>percentage}
      else
        @sectionViewBoxes << { :section => section, :status => status, :results => resultHash }
      end
    end

    respond_to do |format|
      format.html {render :layout => 'application_no_footer'}
      format.json { 
        renderFullTutorialData(@tutorial)
      }
    end
  end

  #return a hash containing complete data of tutorial, including nested records
  def renderFullTutorialData(tutorial)
    $ftd= tutorial.attributes  #ftd means full tutorial data
    $ftd[:sections]=[]
    @tutorial.sections.order("index").each do |section|
      $currSection=section.attributes
      $currSection[:exercises]=[]
      section.exercises.order("index").each do |exercise|
        $currExercise=exercise.attributes
        $currExercise[:template_files]=exercise.template_files
        $currExercise[:test_files]=exercise.test_files
        $currExercise[:output_validators]=exercise.output_validators
        $currSection[:exercises] << $currExercise
      end
      $ftd[:sections] << $currSection
    end
    render json: $ftd
  end

  # GET /tutorials/new
  # GET /tutorials/new.json
  def new
    if(session[:id]==nil)
      params[:message]="Please log in to create a new tutorial."
      render "/index.html.erb"
      return
    end
    @tutorial = Tutorial.new
    @categories = Category.all
  end

  # GET /tutorials/1/edit
  def edit
    @tutorial = Tutorial.find(params[:id])
    @tagNames=[]
    for tag in @tutorial.tags
      @tagNames<<tag.name
    end
    @categories = Category.all
  end

  # POST /tutorials
  # POST /tutorials.json
  def create
    if(session[:id]==nil)
      render json: {message:"Error, cannot create tutorial without user logged in"}, status: :unauthorized
      return
    end

    t=params[:tutorial]
    @tutorial = Tutorial.new
    @tutorial.title=t[:title]
    @tutorial.description=t[:description]
    @tutorial.difficulty=t[:difficulty]
    @tutorial.user_id=session[:id]
    @tutorial.category_id=t[:category_id]
    addTagsToTutorial(@tutorial,params[:tags])

    t[:sections].each_with_index do |sec, index|
      section = Section.new
      section.content=sec[:content];
      section.index=index + 1;
      section.subtitle=sec[:subtitle]
      if sec[:exercises]!=nil
        sec[:exercises].each_with_index do |ex, indx|
          exercise = Exercise.new
          exercise.content=ex[:content];
          exercise.index=indx + 1;
          test_file = TestFile.new
          if ex[:proj_type] == 'c++'
            test_file.file_name="testingfile.cpp"
          else
            test_file.file_name="testingfile.c"
          end
          test_file.content=ex[:testing_file]
          exercise.test_files << test_file;
          exercise.proj_type=ex[:proj_type]
          addValidatorsToExercise(exercise,ex[:validators])
          if ex[:templates]!=nil
            ex[:templates].each_with_index do |templ, ind|
              template = TemplateFile.new
              template.file_name=templ[:fileName]
              template.content=templ[:code]
              template.should_compile=templ[:should_compile]
              exercise.template_files << template
            end
          end
          section.exercises << exercise;
        end
      end
      @tutorial.sections << section;
    end

    if @tutorial.save
      render json: @tutorial, status: :created, location: @tutorial
    else
      render json: @tutorial.errors, status: :unprocessable_entity 
    end
  end

  def addValidatorsToExercise(exercise,validators)
    if validators==nil
      exercise.output_validators.clear
      return
    end
    validator_ids=[]
    for v in validators
      if v[:validator]!=nil && v[:validator]!=""
        validator = OutputValidator.where(:id=>v[:id]).first_or_create()
        validator.validator=v[:validator]
        if v[:args]!=nil && v[:args]!=""
          validator.args=v[:args]
        end
        exercise.output_validators<<validator
        validator_ids<<validator.id
      end
    end

    for validator in exercise.output_validators
      if !validator_ids.include?(validator.id)
        validator.destroy
      end
    end
  end


  def addTagsToTutorial(tutorial,tagsList)
    if tagsList==nil
      return
    end
    tutorial.tags.clear
    tag_ids=[]
    strlist = tagsList.split(',')
    strlist.each do |name|
      newTag = Tag.where(:name=>name).first_or_create()
      newTag.name=name
      tutorial.tags<<newTag
      tag_ids << newTag.id
    end
  end

  # PUT /tutorials/1
  # PUT /tutorials/1.json
  def update
    t = params[:tutorial]
    @tutorial = Tutorial.find(t[:id])
    if @tutorial.user_id != session[:id]
      render json: {:message=>"Could not update. User logged in does not match creator tutorial."}, status: :unauthorized
      return 
    end    
    @tutorial.title=t[:title]
    @tutorial.description=t[:description]
    @tutorial.difficulty=t[:difficulty]
    @tutorial.category_id=t[:category_id]
    addTagsToTutorial(@tutorial,params[:tags])
    updateTutorialSections(@tutorial,t[:sections])
    @tutorial.save
    render json: @tutorial.errors
    return
  end

  def updateTutorialSections(tutorial,sections)
    if sections==nil
      tutorial.sections.clear
      return
    end
    section_ids=[nil]
    sections.each_with_index do |sec,index|
      if sec[:id]!= nil && Section.where("id=? and tutorial_id=?",sec[:id],@tutorial.id).length!=0
        newSection = Section.where("id=? and tutorial_id=?",sec[:id],@tutorial.id).first
      else
        newSection = Section.new
      end
      newSection.content=sec[:content]
      newSection.index=index + 1
      newSection.subtitle=sec[:subtitle]
      updateSectionExercises(newSection,sec[:exercises])
      tutorial.sections<<newSection
      section_ids<<newSection.id
    end
    #go through and delete the sections that no longer belongs to this tutorial
    for section in tutorial.sections
      if !section_ids.include?(section.id)
        section.destroy
      end
    end
  end

  def updateSectionExercises(section, exercises)
    if exercises==nil
      section.exercises=[]
      return
    end
    exercise_ids=[]
    exercises.each_with_index do |exercise, index|
      if exercise[:id]!=nil && section[:id]!=nil && Exercise.where("id=? and section_id=?",exercise[:id],section.id).length!=0
        newExercise=Exercise.where("id=? and section_id=?",exercise[:id],section.id).first
      else
        newExercise = Exercise.new
      end
      newExercise.content=exercise[:content];
      newExercise.index=index + 1;
      newExercise.proj_type=exercise[:proj_type]
      updateExerciseTestFiles(newExercise,exercise[:test_files])
      updateExerciseTemplates(newExercise,exercise[:template_files])
      addValidatorsToExercise(newExercise,exercise[:output_validators])
      section.exercises<<newExercise
      exercise_ids<<newExercise.id
      section.save
    end

    for exercise in section.exercises
      if !exercise_ids.include?(exercise.id)
        exercise.destroy
      end
    end

  end  

  def updateExerciseTemplates(exercise, templates)
    if templates==nil
      exercise.template_files.clear
      return
    end

    template_ids=[]
    templates.each_with_index do |template,index|
      if template[:id]!=nil && exercise[:id]!=nil && TemplateFile.where("id=? and exercise_id=?",template[:id],exercise[:id]).length!=0
        newTemplate = TemplateFile.where("id=? and exercise_id=?",template[:id],exercise[:id]).first
      else
        newTemplate = TemplateFile.new
      end

      newTemplate.file_name=template[:file_name]
      newTemplate.content=template[:content]
      newTemplate.should_compile=template[:should_compile]
      exercise.template_files << newTemplate
      template_ids<<newTemplate.id
    end

    for template_file in exercise.template_files
      if !template_ids.include?(template_file.id)
        template_file.destroy
      end
    end

  end

  def updateExerciseTestFiles(exercise, test_files)
    if test_files==nil
      exercise.test_files.clear
      return
    end

    if exercise.test_files.empty?
      test_file=TestFile.new
    else
      test_file=exercise.test_files[0]
    end
    if exercise.proj_type == 'c++'
      test_file.file_name="testingfile.cpp"
    else
      test_file.file_name="testingfile.c"
    end
    test_file.content=test_files[0][:content]
    exercise.test_files<<test_file
  end

  # DELETE /tutorials/1
  # DELETE /tutorials/1.json
  def destroy
    @tutorial = Tutorial.find(params[:id])
    @tutorial.sections.each do |section|
      section.destroy
    end
    @tutorial.destroy

    respond_to do |format|
      format.html { redirect_to "/" }
      format.json { head :no_content }
    end
  end


  def search_tutorials
    @tutorials = []
    currTags = []
    new_tag = params[:new_tag]
    remove_tag = params[:remove_tag]
    category = params[:category]
    difficulty = params[:difficulty]
    order = params[:order]
    isInverted = (params[:isInverted] == "true")
    if order == "recent"
      orderStr = "updated_at "
    elsif order == "popularity"
      orderStr = "num_ratings "
    else
      orderStr = "rating "
    end
    if isInverted
      orderStr << "ASC"
    else
      orderStr << "DESC"
    end
    if not remove_tag == ""
      session[:currTags].delete(remove_tag.to_i)
    end
    tag = Tag.where("tags.name = ?", new_tag)
    if (new_tag == "" or tag.empty?) and session[:currTags].empty?
      #search 1
      if category == "All" and difficulty == "All"
        @tutorials = Tutorial.order(orderStr)
      elsif category == "All"
        @tutorials = Tutorial.where(:difficulty => difficulty.to_i).order(orderStr)
      elsif difficulty == "All"
        @tutorials = Tutorial.where(:category_id => category.to_i).order(orderStr)
      else
        @tutorials = Tutorial.where(:difficulty => difficulty.to_i, :category_id => category.to_i).order(orderStr)
      end
    else
      if not new_tag == "" and not tag.empty?
        session[:currTags] << tag.first.id
      end
      currTags = Tag.where(:id => session[:currTags])
      currTags.each do |t|
        @tutorials << t.tutorials.pluck(:id)
      end
      @tutorials.each do |x|
        @tutorials[0] = @tutorials[0] & x
      end
      #search 2
      if category == "All" and difficulty == "All"
        @tutorials = Tutorial.where(:id => @tutorials[0]).order(orderStr)
      elsif category == "All"
        @tutorials = Tutorial.where(:id => @tutorials[0], :difficulty => difficulty.to_i).order(orderStr)
      elsif difficulty == "All"
        @tutorials = Tutorial.where(:id => @tutorials[0], :category_id => category.to_i).order(orderStr)
      else
        @tutorials = Tutorial.where(:id => @tutorials[0], :difficulty => difficulty.to_i, :category_id => category.to_i).order(orderStr)
      end
    end
    #Rails.logger.debug(tag.inspect)
    #Rails.logger.debug("==================================================")
    #Rails.logger.debug(tag.first.tutorials.inspect)
    #Rails.logger.debug("==================================================")

    @currTags = currTags
    @tutorialViewBoxes = tutorialViewBox_factory(@tutorials)
    render(:partial => "tutorial_search_partial")
  end

  def tutorialViewBox_factory(tutorials)
    toReturn = []
    status = ""
    tutorials.each do |tutorial|
      total_exercises_complete=0
      total_exercises=0
      if signed_in?
        is_complete = true
        is_attempted = false
        tutorial.sections.each do |section|
          exerciseIds = []
          total_exercises+=section.exercises.length
          section.exercises.each do |exercise|
            exerciseIds << exercise.id
          end
          num_results = Result.where(:exercise_id => exerciseIds, :user_id => current_user.id).size
          num_correct = Result.where(:exercise_id => exerciseIds, :user_id => current_user.id, :is_correct => true).size
          total_exercises_complete+=num_correct
          if num_results > 0
            is_attempted = true
          end
          if num_correct < exerciseIds.size
            is_complete = false
          end
        end
        status = "Not Attempted"
        if is_attempted
          status = "In Progress"
        end
        if is_complete
          status = "Complete"
        end
      end
      category = Category.where(:id => tutorial.category_id).select(:name)
      if signed_in?
        rating = Rating.where(:user_id => current_user.id, :tutorial_id => tutorial.id).first
        if not rating.nil?
          rating = rating.score
        end
        percentage=total_exercises_complete.to_f/total_exercises*100
        toReturn << { :tutorial => tutorial, :status => status, :category => category[0][:name] ,:total_exercises=>total_exercises,:total_exercises_complete=>total_exercises_complete,:percent_complete=>percentage, :rating => rating }
      else
        toReturn << { :tutorial => tutorial, :status => status, :category => category[0][:name] ,:total_exercises=>total_exercises,:total_exercises_complete=>total_exercises_complete,:percent_complete=>percentage}
      end
    end
    return toReturn
  end

  def progress
    if params[:user_id]==nil || params[:tutorial_id]==nil
      render json: {:message =>"Error, nil parameters"}, status: :bad_request
      return
    end

    tutorial=Tutorial.find(params[:tutorial_id])
    numExercises=tutorial.exercises.length
    numCompleted=0
    for exercise in tutorial.exercises
      for result in exercise.results
        if result.user_id=params[:user_id] && result.is_correct
          numCompleted+=1
        end
      end
    end

    render json: {:numCompleted=>numCompleted,:numTotal=>numExercises}

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

end
