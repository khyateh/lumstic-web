class ResponseDecorator < Draper::Decorator
  decorates :response
  decorates_finders
  delegate_all

  def report_data_for_resp_header
  	header = ['count', 'No. of responses']
  	h.escape_javascript('['.html_safe) + h.escape_javascript(header.to_json.html_safe)
  end

  def report_data_for_resp
    #header = ['question.content', 'No. of responses']
    report_data = [self.updated_at,1]
    # puts report_data.inspect
    if report_data.present?
      h.escape_javascript(','.html_safe) + h.escape_javascript(report_data.to_json.html_safe)  
    else
      []
    end
  end

  def self.response_data_for_resp(day,videos)
    report_data = [day.strftime("%m/%d/%y"),videos.count]
    # puts report_data.inspect
    if report_data.present?
      h.escape_javascript(','.html_safe) + h.escape_javascript(report_data.to_json.html_safe)  
    else
      []
    end
  end

  def sort_answers(answers)
    ids_of_questions_in_order = model.survey.ordered_question_tree.map(&:id)
    answers.sort_by { |answer| ids_of_questions_in_order.index(answer.question_id) || 0 }
  end
end
