class FieldAgentAbility < Ability
  def initialize(user_info)
    @user_info = user_info

    can :read, Survey.shared(@user_info[:user_id]) #,  :survey_users => { :user_id => user_info[:user_id] }
    can :read, Survey, :organization_id => @user_info[:org_id]
    can :read, Survey.with_participating_organizations(@user_info[:org_id])
    
    can :report, Survey.shared(@user_info[:user_id]) # SurveyUser , :survey_users => { :user_id => user_info[:user_id] } #Survey, surveys_published_to_me
    can :generate_excel, Survey.shared(user_info[:user_id]) #Survey, surveys_published_to_me
    can :create, Response #, :survey => { :survey_users => { :user_id => user_info[:user_id] } }
    can :manage, Response #, :user_id => user_info[:user_id]
    cannot :destroy, Response
    cannot :provide_state, Response
    can :read, Survey, :organization_id => user_info[:org_id]  
    
  end  
 
end
