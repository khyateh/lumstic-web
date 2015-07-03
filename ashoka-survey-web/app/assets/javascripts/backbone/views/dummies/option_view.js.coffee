# Represents a dummy option in the DOM
SurveyBuilder.Views.Dummies ||= {}

class SurveyBuilder.Views.Dummies.OptionView extends Backbone.View
  ORDER_NUMBER_STEP: 2

  initialize: (@model, @template, @survey_frozen) =>
    # console.log "Dummies.OptionView initialize"
    this.sub_questions = []
    # this.model.on('change', this.render, this)
    this.model.on('change:errors', this.render, this)
    this.model.on('change:id', this.render, this)
    this.model.on('add:sub_question', this.add_sub_question, this)
    this.model.on('change:preload_sub_questions', this.preload_sub_questions, this)
    this.model.on('destroy', this.remove, this)

  render: =>
    console.log "####################Dummies.OptionView render###################"
    data = _.extend(this.model.toJSON().option, {errors: this.model.errors})
    data = _.extend(data, { finalized: @model.get('finalized') })
    $(this.el).html(Mustache.render(@template, data))
    $(this.el).addClass('option')
    $(this.el).find('.add_sub_question').bind('click', this.add_sub_question_model)
    $(this.el).children('div').children('.add_sub_category').bind('click', this.add_sub_category_model)
    $(this.el).children('div').children('.add_sub_multi_record').bind('click', this.add_sub_category_model)

    $(this.el).find('.add-question-btn').bind('click',this.you_clicked_me)
    $(this.el).find('.question-types a').bind('click',this.seleted_a_question)

    $(this.el).find('.delete_option').bind('click', this.delete)
    $(this.el).find('input').bind('keyup', this.update_model)
    @limit_edit() if @survey_frozen
    # console.log "Option Sub Questions "
    # console.dir  this.sub_questions
    group = $("<div class='sub_question_group' style='border:0px solid orange;margin:10px;'>")
    group.sortable({
      items: "> div",
      update: ((event, ui) =>
        window.loading_overlay.show_overlay("Reordering Questions")
        _.delay(=>
          @reorder_questions(event,ui)
        , 10)
      )
    })
    # group.append("<p class='sub_question_group_message'> #{I18n.t('js.questions_for')} #{option.model.get('content')}</p>")
    _(this.sub_questions).each (sub_question) =>
      console.log "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@sub_question"
      x = sub_question.render().el
      $(x).find('input[type=text').addClass('nested-question')
      $(x).find('input[type=number').addClass('nested-question')
      group.append(x)
    
    $(@el).append(group) unless _(this.sub_questions).isEmpty()
    return this

  seleted_a_question: (event) =>
    console.log "seleted_a_question" + event.target.id
    type = event.target.id
    this.model.add_sub_question(type)

  you_clicked_me: (event) =>
    # alert "you_clicked_me"
    $(event.target).prev('.question-types').toggleClass('show');
    return false

  update_model: (event) =>
    console.log "updating option"
    input = $(event.target)
    this.model.set({content: input.val()})
    event.stopImmediatePropagation()

  delete: =>
    # alert " HELLO "
    this.model.destroy()
    window.conditional_ques_count -= @sub_questions.length
    $(".clsass_sub_questions").html(window.conditional_ques_count)

  add_sub_question_model: (event) =>
    type = $(event.target).prev().val()
    this.model.add_sub_question(type)

  add_sub_category_model: (event) =>
    type = $(event.target).data('type')
    this.model.add_sub_question(type)

  add_sub_question: (sub_question_model) =>
    console.log "add_sub_question "
    window.loading_overlay.show_overlay()
    $(this.el).bind('ajaxStop.new_question', =>
      window.loading_overlay.hide_overlay()
      $(this.el).unbind('ajaxStop.new_question')
    )
    sub_question_model.on('destroy', this.delete_sub_question, this)
    type = sub_question_model.get('type')
    question = SurveyBuilder.Views.QuestionFactory.dummy_view_for(type, sub_question_model, @survey_frozen)
    this.sub_questions.push question
    console.log "window.conditional_ques_count",window.conditional_ques_count
    console.log "@sub_questions.length" ,this.sub_questions.length
    window.conditional_ques_count++
    $(".clsass_sub_questions").html(window.conditional_ques_count)
    this.trigger('render_added_sub_question')
    this.render()

  preload_sub_questions: (sub_question_models) =>
    console.log "preload_sub_questions"
    _.each(sub_question_models, (sub_question_model) =>
      this.add_sub_question(sub_question_model)
    )
    this.trigger('render_preloaded_sub_questions')

  # preload_sub_questions: (collection) =>
  #   _.each(collection, (question) =>
  #     this.add_sub_question(question)
  #   )

  delete_sub_question: (sub_question_model) =>
    view = sub_question_model.dummy_view
    @sub_questions = _(@sub_questions).without(view)
    view.remove()
    window.conditional_ques_count--
    $(".clsass_sub_questions").html(window.conditional_ques_count)
    this.trigger('destroy:sub_question')

  # delete_sub_question: (sub_question_model) =>
  #   view = sub_question_model.actual_view
  #   @sub_questions = _(@sub_questions).without(view)
  #   view.remove()

  last_sub_question_order_number: =>
    _.chain(@sub_questions)
      .map((sub_question) => sub_question.model.get('order_number'))
      .max().value()

  set_sub_question_order_numbers: =>
    last_order_number = @last_sub_question_order_number()
    for sub_question in @sub_questions
      index = sub_question.set_order_number(last_order_number)
      @model.sub_question_order_counter = last_order_number + (index * @ORDER_NUMBER_STEP)

  has_no_sub_questions: =>
    @sub_questions.length == 0

  limit_edit: =>
    # For now ( TODO )
    $(this.el).find(".delete_option").hide()
    if @model.get("finalized")
      $(this.el).find(".delete_option").hide()