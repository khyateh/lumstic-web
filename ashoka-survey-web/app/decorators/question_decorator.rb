class QuestionDecorator < Draper::Decorator
  decorates :question
  decorates_finders
  delegate_all
  include ElementNumberable

  def input_tag(f, opts={})
    f.input (opts[:field] || :content), opts.merge(:label => label, :required => mandatory)
  end

  def content_with_answer_count
    model.content + " " + I18n.t('surveys.report.total', :count => model.answers.complete.count)
  end

  def label
    mandatory = model.mandatory ? ' * ' : ' '
    identifier = model.identifier ? ' &#10789; ' : ' '
    question_number + ")  " + content + mandatory + identifier
  end
end
