# A question with a date type answer

class DateQuestion < Question

  def report_data_in_range(start_date,end_date)
  	answers_content = answers_for_reports_in_range(start_date,end_date).map(&:content)
    answers_content.uniq.inject([]) do |data, content|
      data.push [content, answers_content.count(content)]
    end
    # answers_grouped_by_content = answers_for_reports_in_range(start_date,end_date).count(:group => 'answers.content')
    # answers_grouped_by_content.map { |content,count| [content.to_f, count] }
  end

  def report_data
    answers_content = answers_for_reports.map(&:content)
    answers_content.uniq.inject([]) do |data, content|
      data.push [content, answers_content.count(content)]
    end
  end
end
