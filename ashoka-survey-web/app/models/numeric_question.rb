class NumericQuestion < Question
  attr_accessible  :max_value, :min_value

  validates_numericality_of :max_value, :min_value, :allow_nil => true
  validate :min_value_less_than_max_value
  validates :max_value, length: { maximum: 15, message: "should be less than 15 digits"}
  validates :min_value, length: { maximum: 9, message: "should be less than 9 digits" }

  def report_data_in_range(start_date,end_date)
#<<<<<<< Updated upstream
#    answers_grouped_by_content = answers_for_reports_in_range(start_date,end_date).group('answers.content').count
#    answers_grouped_by_content.map { |content,count| [content.to_f, count] }
    
#=======
    answers_grouped_by_content = answers_for_reports_in_range(start_date,end_date).count(:group => 'answers.content').map(&:content)
    answers = answers_grouped_by_content.map { |content,count| [content.to_f, count] }
    report_data = options.map { |option| [option.content, option.report_data(answers)] }
    if report_data.map { |option, count| count }.uniq == [0]
      []
    else
      report_data
    end
#>>>>>>> Stashed changes
  end

  def report_data
    answers_grouped_by_content = answers_for_reports.group('answers.content').count
    answers_grouped_by_content.map { |content,count| [content.to_f, count] }
  end

  def min_value_for_report
    min_value || 0
  end

  def max_value_for_report
    max_value || max_value_in_answers || 0
  end

  private

  def answers_content
    answers.complete.map(&:content)
  end

  def max_value_in_answers
   answers_content.map{ |answer| answer.to_f }.max
  end

  def min_value_less_than_max_value
    if min_value && max_value && (min_value > max_value)
      # errors.add(:min_value, I18n.t('questions.validations.min_value_higher'))
      errors.add(:min_value, "is higher than maximum value")
    end
  end
end
