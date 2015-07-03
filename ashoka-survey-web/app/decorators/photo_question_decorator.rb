class PhotoQuestionDecorator < QuestionDecorator
  decorates :photo_question
  delegate_all

  def input_tag(f, opts={})
    answer = f.object
    photo_url = opts[:disabled] ? answer.photo_url : answer.photo_url(:format => :medium)

    image_thumb = answer.photo_url.present? ? (h.image_tag photo_url, :class => 'large-image') : ''
    photo_field = super(f,  :field => :photo,
                             :as => :file,
                             :input_html => { :disabled => opts[:disabled] })

    ( photo_field + image_thumb).html_safe
  end
end
