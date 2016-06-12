require 'will_paginate/array'
require 'json'


class RespondentsController < ApplicationController
  #before_action :set_respondent, only: [:show, :edit, :update, :destroy, :search]

  # GET /respondents
  def index
   #filtered_surveys = SurveyFilter.new(@surveys, params[:filter]).filter
   # paginated_surveys = filtered_surveys.most_recent.paginate(:page => params[:page], :per_page => 10)
   # @surveys = paginated_surveys.decorate
   # @paginated_surveys = paginated_surveys
    
    @survey_id = params[:survey_id]
    filter = params[:filter] || 'Allocated'
    
    @respondents = Respondent.where(:survey_id => params[:survey_id]).where(:status => filter).search(params[:search_param]) #.paginate(:per_page => 5, :page => params[:page])
    
    # if @respondents.count > 0
    @survey = Survey.find(params[:survey_id]).decorate
    
    authorize! :midline, @survey
    @publishable_users = User.find_by_organization(access_token,@survey.organization_id) 
    #@survey.users_for_organization(access_token, current_user_org)
  
    #@published_users = publishable_users[:published]
    #end
  end
  
  def search
   @survey_id = params[:survey_id]
    @survey = Survey.find(params[:survey_id]).decorate
    @respondents = Respondent.where('respondent_json like ?', '%' + params[:search_param] + '%')
    render :index, :survey_id => params[:survey_id], :search_param => params[:search_param]
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
  respond_to :html, :json
  def update
    @respondent = Respondent.find(params[:id])
    #respond_with @respondent    
    @respondent.update_attributes(params[:respondent])     
    #redirect_to @respondent #, notice: 'Respondent was successfully updated.'
    respond_with @respondent, :notice => 'User allocation successful' 
    
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
      params.permit(:survey_id, :user_id, :respondent_json)
    end
end
