require 'will_paginate/array'
class SurveyDashboardController < ApplicationController
  def index
    @survey = Survey.find(params[:survey_id])
    authorize! :view_survey_dashboard, @survey
    @users_with_responses = User.users_for_ids(access_token, @survey.ids_for_users_with_responses).paginate(:page => params[:page], :per_page => 2)

    # @videos = @survey.responses
    # @video_days = @videos.group_by {|video| video.created_at.to_date }
    # puts @video_days.inspect
    if @survey.responses.first	  
      resp_id = @survey.responses.first.id
      resp = ResponseDecorator.find(resp_id)
      @report_data = resp.report_data_for_resp_header
      for resp_dec in @survey.responses
		    resp = ResponseDecorator.find(resp_dec.id)
		    @report_data << resp.report_data_for_resp
   	  end
	  @report_data << ']'
      #resp_id = @survey.responses.first.id
      #resp = ResponseDecorator.find(resp_id)
      #@report_data = resp.report_data_for_resp_header
      # puts @report_data.inspect
      #@report_data << resp.report_data_for_resp
      #@report_data << ']'
      # puts @report_data.inspect
      @video_days = Response.reponses_grouped(params[:survey_id])
      resp_id = @survey.responses.first.id
      resp = ResponseDecorator.find(resp_id)
      @report_data = resp.report_data_for_resp_header
      puts @report_data
      @video_days.each do |day, videos| 
      @report_data <<  ResponseDecorator.response_data_for_resp(day,videos)
      puts @report_data
      end
      @report_data << ']'
      puts @report_data
    end
  end

  def show
    @survey = Survey.find(params[:survey_id])
    authorize! :view_survey_dashboard, @survey
    @user_id = params[:id].to_i
  end
end
