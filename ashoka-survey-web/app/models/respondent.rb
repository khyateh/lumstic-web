class Respondent < ActiveRecord::Base
 attr_accessible  :user_id, :respondent_json, :survey_id, :response_id, :organization_id
# scope :for_survey, => { where (survey_id => :survey_id)}

  def serializable_hash(opt = nil)
    opt ||= {}
    return JSON.parse(respondent_json)
  end
end
