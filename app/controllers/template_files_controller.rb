class TemplateFilesController < ApplicationController
  # GET /template_files
  # GET /template_files.json
  def index
    @template_files = TemplateFile.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @template_files }
    end
  end

  # GET /template_files/1
  # GET /template_files/1.json
  def show
    @template_file = TemplateFile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @template_file }
    end
  end

  # GET /template_files/new
  # GET /template_files/new.json
  def new
    @template_file = TemplateFile.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @template_file }
    end
  end

  # GET /template_files/1/edit
  def edit
    @template_file = TemplateFile.find(params[:id])
  end

  # POST /template_files
  # POST /template_files.json
  def create
    @template_file = TemplateFile.new(params[:template_file])

    respond_to do |format|
      if @template_file.save
        format.html { redirect_to @template_file, notice: 'Template file was successfully created.' }
        format.json { render json: @template_file, status: :created, location: @template_file }
      else
        format.html { render action: "new" }
        format.json { render json: @template_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /template_files/1
  # PUT /template_files/1.json
  def update
    @template_file = TemplateFile.find(params[:id])

    respond_to do |format|
      if @template_file.update_attributes(params[:template_file])
        format.html { redirect_to @template_file, notice: 'Template file was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @template_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /template_files/1
  # DELETE /template_files/1.json
  def destroy
    @template_file = TemplateFile.find(params[:id])
    @template_file.destroy

    respond_to do |format|
      format.html { redirect_to template_files_url }
      format.json { head :no_content }
    end
  end
end
