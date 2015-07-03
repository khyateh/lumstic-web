##= require ./question_view
SurveyBuilder.Views.Dummies ||= {}

# Represents a dummy radio question on the DOM
class SurveyBuilder.Views.Dummies.QuestionWithOptionsView extends SurveyBuilder.Views.Dummies.QuestionView

  events:
    'keyup input.nestes-question[type=text]': 'handle_textbox_keyup_new'
    'keyup input.nestes-question[type=number]': 'handle_textbox_keyup_new'
    'change input[type=checkbox]': 'handle_checkbox_change_new'
    'click button.add_option': 'add_new_option_model'
    'click button.add_options_in_bulk': 'add_options_in_bulk'

  handle_textbox_keyup_new: (event) =>
    console.log ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    console.dir this.model.id
    console.log ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    this.model.off('change', this.render)
    input = $(event.target)
    propertyHash = {}
    propertyHash[input.attr('name')] = input.val()
    this.update_model(propertyHash)

  handle_checkbox_change_new: (event) =>
    this.model.off('change', this.render)
    input = $(event.target)
    propertyHash = {}
    propertyHash[input.attr('name')] = input.is(':checked')
    this.update_model(propertyHash)

  initialize: (model, template, @survey_frozen) =>
    super
    @options = []
    @can_have_sub_questions = true
    @model.get('options').on('destroy', @delete_option_view, this)
    @model.on('add:options', @add_new_option, this)
    @model.on('preload_options', @preload_options, this)
    this.model.on('change', this.render, this)

  render: =>
    super
    console.log "render QuestionWithOptionsView"
    $(@el).children(".dummy_question_content:not(:has(div.children_content))").append('<div class="children_content" style="border: 1px solid #e0e0e0;border-top: 0;margin-top: -10px;"></div>')
    $(@el).children(".dummy_question_content").click (e) =>
      @show_actual(e)
    # $(@el).children('.dummy_question_content').children(".delete_question").click (e) => 
    #   alert "FADSAsd"
    #   @delete(e)
    # console.dir @options
    $(@el).children(".sub_question_group").html('')
    _(@options).each (option) =>
      # console.dir  option
      # group = $("<div class='sub_question_group'>")
      # group.sortable({
      #   items: "> div",
      #   update: ((event, ui) =>
      #     window.loading_overlay.show_overlay("Reordering Questions")
      #     _.delay(=>
      #       @reorder_questions(event,ui)
      #     , 10)
      #   )
      # })
      # group.append("<p class='sub_question_group_message'> #{I18n.t('js.questions_for')} #{option.model.get('content')}</p>")
      # _(option.sub_questions).each (sub_question) =>
      #   group.append(sub_question.render().el)
      # $(@el).append(group) unless _(option.sub_questions).isEmpty()
    @render_dropdown()
    @limit_edit() if @survey_frozen
    return this

  preload_options: (collection) =>
    collection.each( (model) =>
      @add_new_option(model)
    )

  render_dropdown: () =>
    if @model.has_drop_down_options()
      option_value = @model.get_first_option_value()
      $(@el).find('option').text(option_value)

  add_new_option: (model, options={}) =>
    window.loading_overlay.show_overlay()
    $(this.el).bind('ajaxStop.new_question', =>
      window.loading_overlay.hide_overlay()
      $(this.el).unbind('ajaxStop.new_question')
      )
    switch @model.get('type')
      when 'RadioQuestion'
        template = $('#dummy_radio_option_template').html()
      when 'MultiChoiceQuestion'
        template = $('#dummy_multi_choice_option_template').html()
      when 'DropDownQuestion'
        template = $('#dummy_drop_down_option_template').html()
    view = new SurveyBuilder.Views.Dummies.OptionView(model, template, @survey_frozen)
    @options.push view
    view.on('render_preloaded_sub_questions', @render, this)
    view.on('render_added_sub_question', @render, this)
    view.on('destroy:sub_question', @reorder_questions, this)
    $(@el).children('.dummy_question_content').children('.children_content').append(view.render().el)
    @render_dropdown()
    return view

  delete_option_view: (model) =>
    option = _(@options).find((option) => option.model == model )
    @options = _(@options).without(option)
    @render()

  unfocus: =>
    super
    _(@options).each (option) =>
      _(option.sub_questions).each (sub_question) =>
        sub_question.unfocus()

  reorder_questions: (event, ui) =>
    for option_view in @options
      break if option_view.has_no_sub_questions()
      option_view.set_sub_question_order_numbers()
      @sort_sub_question_views_by_order_number(option_view)

    @reset_sub_question_numbers()
    @hide_overlay(event)

  sort_sub_question_views_by_order_number: (option_view) =>
    option_view.sub_questions = _(option_view.sub_questions).sortBy (sub_question) =>
      sub_question.model.get('order_number')

  hide_overlay: (event) =>
    window.loading_overlay.hide_overlay() if event

  reset_sub_question_numbers: =>
    for option in @options
      for sub_question in option.sub_questions
        index = $(sub_question.el).index()
        parent_question_number = option.model.get('question').question_number
        sub_question.model.question_number = '' + parent_question_number + @parent_option_character(option) + '.' + index

        sub_question.reset_sub_question_numbers() if sub_question.can_have_sub_questions
    @render()

  parent_is_multichoice: (option) =>
    option.model.get('question').get('type') == "MultiChoiceQuestion"

  parent_option_character: (option) =>
    return '' unless @parent_is_multichoice(option)
    first_order_number = option.model.get('question').first_order_number()
    parent_option_number = option.model.get('order_number') - first_order_number
    String.fromCharCode(65 + parent_option_number)

  confirm_if_frozen: =>
    if @survey_frozen
      confirm(I18n.t("js.confirm_add_option_to_finalized_survey"))
    else
      true

  add_new_option_model: (content) =>
    this.model.create_new_option(content) if @confirm_if_frozen()

  add_options_in_bulk: =>
    csv = $(this.el).find('textarea.add_options_in_bulk').val()
    return if csv == ""
    try
      parsed_csv = $.csv.toArray(csv)
    catch error
      alert I18n.t("js.require_csv_format")
      return

    window.loading_overlay.show_overlay("Adding your options. Please wait.")
    _.delay(=>
      @model.destroy_options()
      for content in parsed_csv
        @add_new_option_model(content.trim()) if content && content.trim().length > 0
      window.loading_overlay.hide_overlay()
    , 10)

  hide : =>
    super
    _(this.options).each (option) =>
        _(option.sub_questions).each (sub_question) =>
          sub_question.hide()

  limit_edit: =>
    super
    if @model.get("finalized")
      $(this.el).find("div.add_options_in_bulk").hide()
      $(this.el).find("textarea.add_options_in_bulk").hide()
      $(this.el).find(".add_option").attr("disabled", false)