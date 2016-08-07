class SupervisorAbility < Ability
  def initialize(user_info)
    @user_info = user_info

    can :read, Survey.shared(@user_info[:user_id]) #,  :survey_users => { :user_id => user_info[:user_id] }
    can :read, Survey, :organization_id => @user_info[:org_id]
    can :read, Survey.with_participating_organizations(@user_info[:org_id])
    can :report, Survey.shared(@user_info[:user_id]) # SurveyUser , :survey_users => { :user_id => user_info[:user_id] } #Survey, surveys_published_to_me
    can :archive, Survey.shared(@user_info[:user_id])  #, :survey_users => { :user_id => user_info[:user_id] } 
    can :generate_excel, Survey.shared(user_info[:user_id]) #Survey, surveys_published_to_me
    can :view_survey_dashboard, Survey.shared(@user_info[:user_id]) # SurveyUser , :survey_users => { :user_id => user_info[:user_id] }#Survey, surveys_published_to_me

    can_perform_on_responses_of_surveys_published_to_me(:manage)
    
  end
  
  private

  def surveys_published_to_me
    { :survey_users => { :user_id => @user_info[:user_id] } }
  end

  def can_perform_on_responses_of_surveys_published_to_me(action)
    can action, Response, sql_for_responses_of_surveys_published_to_me do |response|
      SurveyUser.find_by_user_id_and_survey_id(@user_info[:user_id], response.survey_id).present?
    end
  end

  def sql_for_responses_of_surveys_published_to_me
    [
        'responses.survey_id IN (SELECT survey_users.survey_id from survey_users
         WHERE survey_users.user_id = ?)', @user_info[:user_id]
    ]
  end
end
