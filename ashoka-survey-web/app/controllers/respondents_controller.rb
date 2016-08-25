require 'will_paginate/array'
require 'json'


class RespondentsController < ApplicationController
  #before_action :set_respondent, only: [:show, :edit, :update, :destroy, :search]

  # GET /respondents
  def index
    
    @survey_id = params[:survey_id]
    filter = params[:filter]
    if (filter == nil || filter == '')      
      filter = 'Allocated'
    end
    @survey = Survey.find(params[:survey_id]).decorate
    authorize! :midline, @survey   
    
    user_param = ' 1=1 '
    if params[:user_filter]
      if  params[:user_filter][:user_id] 
        user_param = ' user_id in (' + params[:user_filter][:user_id] + ')'      
      end
    end
    if params[:user_filter]
      @user_selected = params[:user_filter][:user_id]
    end
    
    @respondents = Respondent.where(:survey_id => params[:survey_id]).where(user_param).where(:status => filter).search(params[:search_param]).paginate(:page => params[:page] || 1, :per_page => 5)
    puts @respondents
    @publishable_users = User.find_by_organization(access_token,@survey.organization_id)
  end
  
  def search
    @survey_id = params[:survey_id]
    @survey = Survey.find(params[:survey_id]).decorate
    @respondents = Respondent.where('respondent_json like ?', '%' + params[:search_param] + '%').paginate(:page => params[:page], :per_page => 2)
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
  puts params
  if (params[:respondent_ids])
   puts params[:respondent_ids]
  else 
    @respondent = Respondent.find(params[:id])
    # respond_with @respondent    
    @respondent.update_attributes(params[:respondent])     
    # redirect_to @respondent #, notice: 'Respondent was successfully updated.'
    respond_with @respondent, :notice => 'User allocation successful' 
   end 
  end

  # PATCH/PUT /respondents/
  respond_to :html, :json
  def update_bulk
    response_ids = params['response_ids']
    selected_user_id = params['sel_user_id']
    @survey_id = params['survey_id']     
    @survey = Survey.find(@survey_id) #.decorate
    authorize! :midline, @survey   
    
    if response_ids
    response_ids.each do |res_id|      
      resp = Respondent.find(res_id)
      resp.update_attribute(:user_id, selected_user_id) if resp
    end
    end
    
    @respondents = Respondent.where(:survey_id => params[:survey_id]).where(:status => 'Allocated').paginate(:page => params[:page] || 1, :per_page => 25)
    @publishable_users = User.find_by_organization(access_token,@survey.organization_id)
    render :index, :survey_id => @survey_id
    flash[:notice] = 'User allocation successfully completed'
    # redirect_to respondents_url(:survey_id => @survey_id)
    # respond_with @respondents,:controller => 'respondents', :survey_id => @survey_id
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
