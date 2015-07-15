##= require ./question_view
SurveyBuilder.Views.Dummies ||= {}

# Represents a dummy category on the DOM
class SurveyBuilder.Views.Dummies.CategoryView extends SurveyBuilder.Views.Dummies.QuestionView
  ORDER_NUMBER_STEP: 2

  events:
    'keyup input[type=text]': 'handle_textbox_keyup'
    'keyup input[type=number]': 'handle_textbox_keyup'
    'mousewheel input[type=number]': 'handle_element_mouseout'
    'blur input[type=text]': 'handle_survey_events'
    'blur input[type=number]': 'handle_survey_events'
    'change input[type=checkbox]': 'handle_checkbox_change'
    'click a.copy_question':'clear_focus'

  initialize: (@model, @template, @survey_frozen) =>
    @sub_questions = []
    @model.dummy_view = this
    @can_have_sub_questions = true
    @model.on('keyup', @render, this)
    @model.on('mouseout', @render, this)
    @model.on('blur', @render, this)
    @model.on('change:errors', @render, this)
    @model.on('change:preload_sub_questions', @preload_sub_questions, this)
    @model.on('add:sub_question', @add_sub_question, this)
    @on('destroy:sub_question', @reorder_questions, this)

  render: =>
    data = @model.toJSON().category
    data = _(data).extend({ question_number: @model.question_number })
    data = _(data).extend({ has_multi_record_ancestor: @model.get('has_multi_record_ancestor') })
    data = _(data).extend({duplicate_url: @model.duplicate_url()})
    _(data).extend({ finalized: @model.get('finalized') })
    data.question = _.extend(@model.toJSON().question)
    data.allow_identifier = @allow_identifier()
    $(@el).css({'border':'1px solid orange'})
    $(@el).css({'margin':'2px'})
    $(@el).html('<div class="dummy_category_content">' + Mustache.render(@template, data) + '</div>')
    $(@el).addClass("dummy_category")

    $(@el).children('.dummy_question_content').children(".top_level_content").html(Mustache.render(@template, data))
    $(@el).addClass("dummy_question")

    $(@el).children(".dummy_category_content").click (e) =>
      $(@el).css({'box-shadow':'-1px 4px 30px rgba(0, 0, 0, 0.5)' ,'-webkit-box-shadow':'-1px 4px 30px rgba(0, 0, 0, 0.5)' ,'-moz-box-shadow':'-1px 4px 30px rgba(0, 0, 0, 0.5)'})

    $(@el).children('.dummy_category_content').find(".delete_category").click (e) => 
      @delete(e)
      window.conditional_ques_count -= @sub_questions.length
      $(".clsass_sub_questions").html(window.conditional_ques_count)
    $(@el).children('.dummy_category_content').find(".copy_question").click (e) =>
      @clear_focus()
      @model.save() 
      @save_all_changes(e)
    $(@el).children(".dummy_category_content").children('.collapse_category').click (e) => 
      @toggle_collapse()

    $(this.el).find('.add_sub_question').bind('click', this.add_sub_question_model)
    $(this.el).find('.add_sub_category').bind('click', this.add_sub_category_model)
    $(this.el).find('.add_sub_multi_record').bind('click', this.add_sub_category_model)

    $(this.el).find('.add-question-btn').bind('click',this.you_clicked_me)
    $(this.el).find('.question-types a').bind('click',this.seleted_a_question)

    $(@el).find('abbr').show() if @model.get('mandatory')

    group = $("<div class='sub_question_group'>")
    _(@sub_questions).each (sub_question) =>
      group.sortable({
        items: "> div",
        update: ((event, ui) =>
          window.loading_overlay.show_overlay("Reordering Questions")
          _.delay(=>
            @reorder_questions(event,ui)
          , 10)
        )
      })
      group.append(sub_question.render().el)
    
    $(@el).append(group) unless _(@sub_questions).isEmpty()
    @collapse(false) if @collapsed
    @limit_edit() if @survey_frozen
    return this

  seleted_a_question: (event) =>
    type = event.target.id
    this.model.add_sub_question(type)

  you_clicked_me: (event) =>
    $(event.target).prev('.question-types').toggleClass('show')
    return false

  clear_focus: =>
    $('input').blur()
    @render()

  add_sub_question_model: (event) =>
    type = $(event.target).prev().val()
    this.model.add_sub_question(type)

  add_sub_category_model: (event) =>
    type = $(event.target).data('type')
    this.model.add_sub_question(type)

  add_sub_question: (sub_question_model) =>
    window.loading_overlay.show_overlay()
    $(this.el).bind('ajaxStop.new_question', =>
      window.loading_overlay.hide_overlay()
      $(this.el).unbind('ajaxStop.new_question')
    )
    sub_question_model.on('destroy', this.delete_sub_question, this)
    type = sub_question_model.get('type')
    question = SurveyBuilder.Views.QuestionFactory.dummy_view_for(type, sub_question_model, @survey_frozen)
    this.sub_questions.push question
    window.conditional_ques_count++
    $(".clsass_sub_questions").html(window.conditional_ques_count)
    this.trigger('render_added_sub_question')
    this.render()

  preload_sub_questions: (sub_question_models) =>
    _.each(sub_question_models, (sub_question_model) =>
      @add_sub_question(sub_question_model)
    )
    this.trigger('render_preloaded_sub_questions')

  delete_sub_question: (sub_question_model) =>
    view = sub_question_model.dummy_view
    @sub_questions = _(@sub_questions).without(view)
    view.remove()
    window.conditional_ques_count--
    $(".clsass_sub_questions").html(window.conditional_ques_count)
    @trigger('destroy:sub_question')

  show_actual: (event) =>
    $(@el).children('.dummy_category_content').addClass("active")

  collapse: (animate=true) =>
    @collapsed = true
    $(@el).children('div.sub_question_group').hide(animate ? 'slow' : '')
    $(@el).children('.dummy_category_content').children('.collapse_category').html('&#9658;')

  uncollapse: =>
    @collapsed = false
    $(@el).children('div.sub_question_group').show('slow')
    $(@el).children('.dummy_category_content').children('.collapse_category').html('&#9660;')

  toggle_collapse: =>
    if @collapsed
      @uncollapse()
    else
      @collapse()

  unfocus: =>
    $(@el).children('.dummy_category_content').removeClass("active")
    _(@sub_questions).each (sub_question) =>
      sub_question.unfocus()

  reorder_questions: (event, ui) =>
    last_order_number = @last_sub_question_order_number()

    _(@sub_questions).each (sub_question) =>
      index = $(sub_question.el).index() + 1
      sub_question.model.set({order_number: last_order_number + (index * @ORDER_NUMBER_STEP)}, {silent: true})
      @model.sub_question_order_counter = last_order_number + (index * @ORDER_NUMBER_STEP)

    @sub_questions = _(@sub_questions).sortBy (sub_question) =>
      sub_question.model.get('order_number')

    @reset_sub_question_numbers()
    @hide_overlay(event)

  hide_overlay: (event) =>
    window.loading_overlay.hide_overlay() if event

  last_sub_question_order_number: =>
    _.chain(@sub_questions)
      .map((sub_question) => sub_question.model.get('order_number'))
      .max().value()

  reset_sub_question_numbers: =>
    _(@sub_questions).each (sub_question) =>
      index = $(sub_question.el).index()
      sub_question.model.question_number = @model.question_number + '.' + (index + 1)
      sub_question.reset_sub_question_numbers() if sub_question.can_have_sub_questions
    @render()

  save_all_changes: =>
    $(@el).trigger("copy_question.save_all_changes", this)

  copy_question: =>
    $(@el).children('.dummy_category_content').children(".copy_question_hidden").click();

  limit_edit: =>
    super
    if @model.get("finalized")
      $(this.el).find(".delete_category").remove()
      $(this.el).find(".delete_option").hide()
      $(this.el).find(".add_options_in_bulk").hide()
      $(this.el).find(".add_option").attr("disabled", false)
      $(this.el).find(".textarea.add_options_in_bulk").hide()

