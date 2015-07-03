class RadioQuestion < QuestionWithOptions
  
  def report_data_in_range(start_date,end_date)
    answers = answers_for_reports_in_range(start_date,end_date)
    report_data = options.map { |option| [option.content, option.report_data(answers)] }
    if report_data.map { |option, count| count }.uniq == [0]
      []
    else
      report_data
    end
  end
  
end
