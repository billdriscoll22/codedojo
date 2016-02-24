require 'childprocess'

class ExercisesController < ApplicationController
  # GET /exercises/1/compile
  # POST /exercises/1/compile
  def compile
    @exercise = Exercise.find(params[:id])

   #ensure Emscripten is ready
    unless File.exist?("/tmp/.emscripten")
      setup_process = ChildProcess.build('emcc')
      setup_process.environment["HOME"] = "/tmp"
      setup_process.start
      setup_process.wait
    end

    if params[:code].nil?
      render :json => {:error => "code property is required"}, :status => 500
      return
    end
    in_files = params[:code]
    if signed_in?
      in_files.each do |in_file|
        user_file = UserFile.find(in_file[:id])
        if user_file != nil
          in_file.delete(:id)
          in_file.delete(:created_at)
          in_file.delete(:updated_at)
          in_file.delete(:isClean)
          in_file.delete("$$hashKey")
          user_file.update_attributes(in_file)
        else
          UserFile.create do |f|
            f.content = template_file.content
            f.exercise_id = template_file.exercise_id
            f.file_name = template_file.file_name
            f.user_id = current_user.id
            f.should_compile = template_file.should_compile
          end
        end
      end
    end

    test_files = TestFile.where("exercise_id =?", params[:id])

    prejs_path = Rails.root.join('public', 'js', 'prejs.js')
    postjs_path = Rails.root.join('public', 'js', 'postjs.js')

    exit_status = 1
    prog_text = ""
    stdout_text = ""
    stderr_text = ""
    build_stdout_r, build_stdout_w = IO.pipe
    build_stderr_r, build_stderr_w = IO.pipe

    Dir.mktmpdir { |dir|
      # write files
      in_files.each do |in_file|
        open("#{dir}/#{in_file[:file_name]}", "w") {|f|
          f.write(in_file[:content])
        }
      end
      test_files.each do |test_file|
        open("#{dir}/#{test_file.file_name}", "w") {|f|
          f.write(test_file.content)
        }
      end

      out_path = "#{dir}/output.js"

      # launch compile process
      begin
        args = []

        if @exercise.proj_type == "c" or @exercise.proj_type == "c++"
          if @exercise.proj_type == "c"
            args.push('emcc')
          else
            args.push('em++')
          end
          args = args + ['-s', 'EXPORTED_FUNCTIONS=[\'_main\', \'_runTests\']',
                         '-s', 'UNALIGNED_MEMORY=1',
                         '-Wall',
                         '--pre-js', prejs_path.to_s,
                         '--post-js', postjs_path.to_s,
                         '-o', 'output.js']
          if @exercise.proj_type == "c++"
            args.push('--jcache')
          end

          in_files.each do |in_file|
            if in_file[:should_compile]
              args.push(in_file[:file_name])
            end
          end

          test_files.each do |test_file|
              args.push(test_file.file_name)
          end
        elsif @exercise.proj_type == "makefile"
          args.push('emmake')
        else
          render :json => {:error => "exercise project type is unknown"}, :status => 500
          return
        end

        compile_process = ChildProcess.build(*args)
        compile_process.io.stdout = build_stdout_w
        compile_process.io.stderr = build_stderr_w
        compile_process.environment["HOME"] = "/tmp"
        compile_process.cwd = dir
        compile_process.start

        build_stdout_w.close
        build_stderr_w.close

        begin
          compile_process.poll_for_exit(30)
          exit_status = compile_process.exit_code
          if exit_status == 0
            begin
              out_file = File.open(out_path, 'r')
              prog_text = out_file.read
            rescue
              exit_status = 1
            end
          end
        rescue ChildProcess::TimeoutError
          out_file = nil
          compile_process.stop
        end

        begin
          loop {stdout_text << build_stdout_r.readpartial(8192)}
        rescue EOFError
        end
        begin
          loop {stderr_text << build_stderr_r.readpartial(8192)}
        rescue EOFError
        end

      ensure
        out_file.close unless out_file.nil?
        build_stdout_r.close
        build_stderr_r.close
      end

    }

    ignore_warnings = ["clang: warning: argument unused during compilation: '-nostdinc++'\n",
                       "clang: warning: argument unused during compilation: '-nostdinc'\n"]

    ignore_warnings.each do |warning|
      if stderr_text[warning]
        stderr_text = stderr_text.gsub(warning, "")
      end
    end

    output_validators = OutputValidator.where("exercise_id = ?", params[:id])

    render :json => {:result => {:exit => exit_status,
                                 :programtext => prog_text,
                                 :stdout => stdout_text,
                                 :stderr => stderr_text,
                                 :validators => output_validators}}
  end

  # GET /exercises
  # GET /exercises.json
  def index
    @exercises = Exercise.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @exercises }
    end
  end

  # GET /exercises/1
  # GET /exercises/1.json
  def show
    @exercise = Exercise.find(params[:id])
		section = Section.find(@exercise.section_id)
		@exercises = section.exercises.order("index")
		@tutorial_id = section.tutorial_id
		@section_name = section.subtitle

    if signed_in?
      @result = Result.where(:user_id => current_user.id, :exercise_id => params[:id]).first
      if @result and @result.is_correct
        @exercise_correct = true
      else
        @exercise_correct = false
      end
    else
      @result = nil
      @exercise_correct = false
    end
 
    #respond_to do |format|
     # format.html # show.html.erb
      #format.json { render json: @exercise }
    #end
    render :layout => 'application_no_footer'
  end

  # GET /exercises/new
  # GET /exercises/new.json
  def new
    @exercise = Exercise.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @exercise }
    end
  end

  # GET /exercises/1/edit
  def edit
    @exercise = Exercise.find(params[:id])
  end

  # POST /exercises
  # POST /exercises.json
  def create
    @exercise = Exercise.new(params[:exercise])

    respond_to do |format|
      if @exercise.save
        format.html { redirect_to @exercise, notice: 'Exercise was successfully created.' }
        format.json { render json: @exercise, status: :created, location: @exercise }
      else
        format.html { render action: "new" }
        format.json { render json: @exercise.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /exercises/1
  # PUT /exercises/1.json
  def update
    @exercise = Exercise.find(params[:id])

    respond_to do |format|
      if @exercise.update_attributes(params[:exercise])
        format.html { redirect_to @exercise, notice: 'Exercise was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @exercise.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /exercises/1
  # DELETE /exercises/1.json
  def destroy
    @exercise = Exercise.find(params[:id])
    @exercise.destroy

    respond_to do |format|
      format.html { redirect_to exercises_url }
      format.json { head :no_content }
    end
  end

	def next
		exercise = Exercise.find(params[:id])
		section = Section.find(exercise.section_id)
		exercises = section.exercises.order("index")
		if exercise.index == exercises.size
			url = url_for(:action => 'show', :controller => 'tutorials', :id => section.tutorial_id)
		else
			url = url_for(exercises[exercise.index])
		end
		redirect_to(url)

	end

end
