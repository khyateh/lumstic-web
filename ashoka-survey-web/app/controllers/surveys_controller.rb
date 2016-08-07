require 'will_paginate/array'

class SurveysController < ApplicationController
  load_resource :only => :index
  authorize_resource
  after_filter(:only => [:create]) { send_to_mixpanel("Survey created") }
  after_filter(:only => [:destroy]) { send_to_mixpanel("Survey destroyed", {:survey => @survey.name}) if @survey.present? }
  after_filter(:only => [:finalize]) { send_to_mixpanel("Survey finalized", {:survey => @survey.name}) if @survey.present? }
  after_filter(:only => [:archive]) { send_to_mixpanel("Survey archived", {:survey => @survey.name}) if @survey.present? }
  #  before_filter :redirect_to_https, :only => :index

  def index
    @surveys ||= Survey.none
    #@surveys.each do |sur|
    #  sur.midline_surveys.all      
    #end
    filtered_surveys = SurveyFilter.new(@surveys, params[:filter]).filter
    paginated_surveys = filtered_surveys.most_recent.paginate(:page => params[:page], :per_page => 10)    
    @surveys = paginated_surveys.decorate
    puts 'Surveys'
   # puts paginated_surveys
    @paginated_surveys = paginated_surveys    
    @organizations = Organization.all(access_token)    
  end

  def destroy
    @survey = Survey.find(params[:id])
    @survey.delete_self_and_associated if @survey.deletable?
    flash[:notice] = t "flash.survey_deleted"
    redirect_to(surveys_path)
  end

  def create
    @survey = Survey.new(params[:survey])
    @survey.organization_id = current_user_org
    @ismidline = false
    @survey.name ||= I18n.t('js.untitled_survey')
    @survey.expiry_date ||= 5.days.from_now
    @survey.description ||= "Description goes here"

    @survey.save
    flash[:notice] = t "flash.survey_created"
    redirect_to survey_build_path(:survey_id => @survey.id)
  end

  def build  
    @survey = SurveyDecorator.find(params[:survey_id])
    @ismidline = @survey.parent_id ? true : false
  end

  def finalize   
    @survey = Survey.find(params[:survey_id])
    if !@survey.finalize
      flash[:error] = @survey.errors.messages 
      redirect_to survey_build_path      
    else      
      flash[:notice] = t "flash.survey_finalized", :survey_name => @survey.name
      redirect_to edit_survey_publication_path(@survey.id)
     end
  end

  def archive
    @survey = Survey.find(params[:survey_id])
    if @survey.archive
      flash[:notice] = t("flash.survey_archived", :survey_name => @survey.name)
    else
      flash[:error] = @survey.errors.messages
    end
    redirect_to surveys_path
  end

  def report
    @survey = SurveyDecorator.find(params[:id])
    responses = Response.accessible_by(current_ability)
    start_date = params[:from]
    end_date = params[:to]
    if start_date == "" 
      start_date = nil
    end
    if end_date == "" 
      end_date=nil
    end
    
    @date_range_start = start_date || -100.days.from_now
    @date_range_end = end_date || 1.days.from_now
    # responses = Response.accessible_by(current_ability).first
    # @complete_responses_count = responses.where(:status => 'complete',:blank => false).count
    @complete_responses_count = @survey.complete_responses_count(current_ability)
    # @markers = @survey.responses.where(:status => "complete").to_gmaps4rails
    
    @response = @survey.responses.where(:status => "complete").where.not(:latitude => nil)
    if @response
      @hash = Gmaps4rails.build_markers(@response) do |response, marker|
      marker.lat response.latitude
      marker.lng response.longitude
    end    
    end
    
    
    
  end
  
  def midline
   @survey = Survey.find(params[:survey_id])
   flash[:notice] = t "flash.midline_created"
   job = @survey.delay(:queue => 'survey_duplication').duplicate(:organization_id => current_user_org, :parent_id => @survey.id, :retainName => true)
   sleep 5
   redirect_to surveys_path + '?filter=drafts'
  end
 
  private

  def redirect_to_https
    # Need request.head? because mobile makes a HEAD request to this same path and Titanium
    # since doesn't follow redirects, we can't redirect to https:// in that case.
    redirect_to :protocol => "https://" if !request.ssl? && !request.head?
  end
end
