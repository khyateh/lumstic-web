module Api
  module V1
    class DeepSurveysController < APIApplicationController
      authorize_resource :class => Survey


      def index
         Survey.current_user = current_user_info[:user_id]
         surveys = Survey.accessible_by(current_ability).active_plus(extra_survey_ids)
	 render :json => surveys, include: [ 'questions', 'categories', :respondents], :each_serializer => DeepSurveySerializer        
      end

      private

      def extra_survey_ids
        extra_survey_ids = params[:extra_surveys] || ""
        extra_survey_ids.split(',').map(&:to_i)
      end
    end
  end
end