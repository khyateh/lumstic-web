class Respondent < ActiveRecord::Base
  def serializable_hash(opt = nil)
    opt ||= {}
    return {:id=> id, :identifiers => JSON.parse(respondent_json) }
  end
end
