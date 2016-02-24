class OutputValidatorsController < ApplicationController
  # GET /output_validators
  # GET /output_validators.json
  def index
    @output_validators = OutputValidator.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @output_validators }
    end
  end

  # GET /output_validators/1
  # GET /output_validators/1.json
  def show
    @output_validator = OutputValidator.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @output_validator }
    end
  end

  # GET /output_validators/new
  # GET /output_validators/new.json
  def new
    @output_validator = OutputValidator.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @output_validator }
    end
  end

  # GET /output_validators/1/edit
  def edit
    @output_validator = OutputValidator.find(params[:id])
  end

  # POST /output_validators
  # POST /output_validators.json
  def create
    @output_validator = OutputValidator.new(params[:output_validator])

    respond_to do |format|
      if @output_validator.save
        format.html { redirect_to @output_validator, notice: 'Output validator was successfully created.' }
        format.json { render json: @output_validator, status: :created, location: @output_validator }
      else
        format.html { render action: "new" }
        format.json { render json: @output_validator.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /output_validators/1
  # PUT /output_validators/1.json
  def update
    @output_validator = OutputValidator.find(params[:id])

    respond_to do |format|
      if @output_validator.update_attributes(params[:output_validator])
        format.html { redirect_to @output_validator, notice: 'Output validator was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @output_validator.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /output_validators/1
  # DELETE /output_validators/1.json
  def destroy
    @output_validator = OutputValidator.find(params[:id])
    @output_validator.destroy

    respond_to do |format|
      format.html { redirect_to output_validators_url }
      format.json { head :no_content }
    end
  end
end
