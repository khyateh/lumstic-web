class MultiChoiceQuestion < QuestionWithOptions
  

  # def report_data_in_range(start_date,end_date)
  #   answers_grouped_by_content = answers_for_reports_in_range(start_date,end_date).count(:group => 'answers.content')
  #   answers_grouped_by_content.map { |content,count| [content.to_f, count] }
  # end

  def report_data_in_range(start_date,end_date)
    choice_ids = answers_for_reports_in_range(start_date,end_date).joins(:choices).pluck('choices.option_id').map(&:to_i)
    report_data = options.map { |option| [option.content, choice_ids.count(option.id)] }
    if report_data.map { |option, count| count }.uniq == [0]
      []
    else
      report_data
    end
  end

  def report_data
    choice_ids = answers_for_reports.joins(:choices).pluck('choices.option_id').map(&:to_i)
    report_data = options.map { |option| [option.content, choice_ids.count(option.id)] }
    if report_data.map { |option, count| count }.uniq == [0]
      []
    else
      report_data
    end
  end

  def reporter
    MultiChoiceQuestionReporter.decorate(self)
  end
end
