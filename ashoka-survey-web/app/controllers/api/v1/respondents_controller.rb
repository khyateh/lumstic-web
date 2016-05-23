module Api
  module V1
    class RespondentsController < APIApplicationController
      authorize_resource :class => Respondent

      def index
         respondents = Respondent.accessible_by(current_ability)
         render :json => respondents
      end

    end
  end
end

