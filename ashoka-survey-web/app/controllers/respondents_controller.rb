class RespondentsController < ApplicationController
  before_action :set_respondent, only: [:show, :edit, :update, :destroy]

  # GET /respondents
  def index
    @respondents = Respondent.all
  end

  # GET /respondents/1
  def show
  end

  # GET /respondents/new
  def new
    @respondent = Respondent.new
  end

  # GET /respondents/1/edit
  def edit
  end

  # POST /respondents
  def create
    @respondent = Respondent.new(respondent_params)

    if @respondent.save
      redirect_to @respondent, notice: 'Respondent was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /respondents/1
  def update
    if @respondent.update(respondent_params)
      redirect_to @respondent, notice: 'Respondent was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /respondents/1
  def destroy
    @respondent.destroy
    redirect_to respondents_url, notice: 'Respondent was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_respondent
      @respondent = Respondent.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def respondent_params
      params.require(:respondent).permit(:survey_id, :user_id, :respondent_json)
    end
end
