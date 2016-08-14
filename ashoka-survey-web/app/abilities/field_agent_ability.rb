class FieldAgentAbility < Ability
  def initialize(user_info)
    @user_info = user_info

    #can :read, Survey.shared(@user_info[:user_id]) #,  :survey_users => { :user_id => user_info[:user_id] }
    # can :read, Survey, :organization_id => @user_info[:org_id]
    # can :read, Survey.with_participating_organizations(@user_info[:org_id])
    can :create, Survey, :survey_users => { :user_id => user_info[:user_id] }
    can :index, Survey, :survey_users => { :user_id => user_info[:user_id] }
    can :read, Survey.shared(@user_info[:user_id]) 
    can :report, Survey.shared(@user_info[:user_id]) # SurveyUser , :survey_users => { :user_id => user_info[:user_id] } #Survey, surveys_published_to_me
    can :generate_excel, Survey.shared(user_info[:user_id]) #Survey, surveys_published_to_me
    can_perform_on_responses_of_surveys_published_to_me(:manage)  
    
    #can :index, Response, :survey => {:survey_users => {:user_id => @user_info[:user_id]}}
    #can :create, Response, :survey => {:survey_users => {:user_id => @user_info[:user_id]}} #, :organization_id => { :user_id => user_info[:org_id] }    
    #can :create, Response #, :survey => { :survey_users => { :user_id => user_info[:user_id] } }
    #can :destroy, Response,  :user_id => user_info[:user_id]
    #can :manage, Response,  :user_id => user_info[:user_id]
    
    cannot :destroy, Response
    cannot :provide_state, Response
    # can :read, Survey, :organization_id => user_info[:org_id]  
    
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
