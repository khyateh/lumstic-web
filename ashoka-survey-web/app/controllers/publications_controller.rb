class PublicationsController < ApplicationController
  before_filter :require_finalized_survey

  after_filter :only => [:destroy] { send_to_mixpanel("Survey unpublished", { :survey => @survey.name}) if @survey.present? }

  def edit
    @survey = Survey.find(params[:survey_id]).decorate
    authorize! :edit_publication, @survey
    publishable_users = @survey.users_for_organization(access_token, current_user_org)
    @published_users = publishable_users[:published]
    @unpublished_users = publishable_users[:unpublished]

    partitioned_organizations = @survey.partitioned_organizations(access_token)
    @shared_organizations = partitioned_organizations[:participating]
    @unshared_organizations = partitioned_organizations[:not_participating]
    create_respondents_list    
  end

  def update
    survey = Survey.find(params[:survey_id])
    authorize! :update_publication, survey
    publisher = Publisher.new(survey, access_token, params[:survey])
    if publisher.publish(:organization_id => current_user_org)
      flash[:notice] = t "flash.survey_published", :survey_name => survey.name
      send_to_mixpanel("Survey published", { :survey => survey.name })
      redirect_to surveys_path
    else
      flash[:error] = publisher.errors.full_messages.join(', ')
      redirect_to(:back)
    end
  end

  def unpublish
    @survey = Survey.find(params[:survey_id])
    authorize! :edit_publication, @survey
    if @survey.published?
      field_agents = @survey.users_for_organization(access_token, current_user_org)
      @published_users = field_agents[:published]
      @unpublished_users = field_agents[:unpublished]
    else
      redirect_to surveys_path
      flash[:error] = t "flash.unpublish_draft_survey"
    end
  end

  def destroy
    @survey = Survey.find(params[:survey_id])
    authorize! :update_publication, @survey
    publisher = Publisher.new(@survey, access_token, params[:survey])
    publisher.unpublish_users
    redirect_to surveys_path
    flash[:notice] = "Unpublished users successfully"
  end

  private

  def require_finalized_survey
    survey = Survey.find(params[:survey_id])
    unless survey.finalized?
      redirect_to surveys_path
      flash[:error] = t "flash.publish_draft_survey"
    end
  end
  
  private
  def create_respondents_list
   if @survey.parent_id && !@survey.published_on
     #Retrieve the reponses from the existing survey and create respondents list
      results = ActiveRecord::Base.connection.execute(create_respondents_list_sql)
      puts results
   end
  end
  
  def create_respondents_list_sql
   "insert into respondents (survey_id, response_id, organization_id, user_id, location, created_at,updated_at, respondent_json)
    (select t1.survey_id, t1.id, t1.organization_id as organization_id, t1.user_id, t1.location, current_timestamp,current_timestamp, row_to_json(t1)
    from (  select sur.id as survey_id, res.id as id, res.organization_id as organization_id, res.user_id, res.location,
    ( select array_to_json(array_agg(row_to_json(t))) 
    from
    (select q.id as Question_id,  q.type as Question_type,
    r.location as Location, a.content as Answer_content
    from surveys s 
    inner join questions q on q.survey_id = s.id    
    inner join responses r on s.parent_id = r.survey_id
    inner join answers a on a.question_id = q.original_question_id and a.response_id = r.id
    where
    q.identifier = true and r.status='complete' and
    r.organization_id =res.organization_id and s.id=sur.id
    order by r.id ) t) as identifiers
    from surveys sur
    inner join
    responses res on sur.parent_id=res.survey_id and res.organization_id=sur.organization_id
    where 
    not exists (select id from respondents where survey_id = sur.id and response_id = res.id)
    and sur.id = #{@survey.id}
    ) t1)"
  end
   
end
