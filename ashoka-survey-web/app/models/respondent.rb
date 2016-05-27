class Respondent < ActiveRecord::Base
  def serializable_hash(opt = nil)
    opt ||= {}
    return JSON.parse(respondent_json)
  end
end
