SurveyBuilder.Views.Dummies ||= {}

# Represents a dummy question on the DOM
class SurveyBuilder.Views.Dummies.QuestionView extends Backbone.View
  ORDER_NUMBER_STEP: 2
  events:
    'blur input.ratingNo': 'render_view'
    'click a.copy_question':'clear_focus'

  initialize: (@model, @template, @survey_frozen) =>
    @model.dummy_view  = this
    @can_have_sub_questions = true
    @model.on('keyup', @render, this)
    @model.on('mousewheel', @render, this)
    @model.on('blur', @render, this)
    @model.on('change:errors', @render, this)
    @model.on('save:completed', @renderImageUploader, this)
    @model.on('save:completed', @render, this)
    @model.on('change:id', @render, this)

  render: =>
    $(@el).html('<div class="dummy_question_content"><div class="top_level_content"></div></div>') if $(@el).is(':empty')
    @model.set('content', I18n.t('js.untitled_question')) if _.isEmpty(@model.get('content'))
    json = _.extend(@model.toJSON())
    data = _.extend(@model.toJSON().question, {errors: @model.errors, image_url: @model.get('image_url')})
    data = _(data).extend({question_number: @model.question_number})
    data = _(data).extend({duplicate_url: @model.duplicate_url()})
    data = _(data).extend({image_upload_url: @model.image_upload_url()})
    data.question = _.extend(@model.toJSON().question)
    data.allow_identifier = @allow_identifier()
    $(@el).children('.dummy_question_content').children(".top_level_content").html(Mustache.render(@template, data))
    $(@el).addClass("dummy_question")
    $(@el).find('abbr[name="mandatory"]').show() if @model.get('mandatory')
    $(@el).find('abbr[name="identifier"]').show() if @model.get('identifier')
    $(@el).find('.star').raty({
      readOnly: true,
      number: @model.get('max_length') || 5
    })
    
    # $(@el).children(".dummy_question_content").find('input[type=text]').bind('keydown',@handle_survey_events)      
    # $(@el).children(".dummy_question_content").find('input[type=number]').bind('keydown',@handle_survey_events)
    $(@el).find('input[type=text]').bind('keyup',@handle_survey_events)      
    $(@el).find('input[type=number]').bind('keyup',@handle_survey_events)    
    $(@el).find('input[type=number]').bind('mousewheel',@handle_element_mouseout)
    $(@el).find('input[type=number]').bind('change',@handle_element_mouseout)
    $(@el).find('input[type=number]').bind('blur',@handle_survey_events)
    $(@el).find('input[type=text]').bind('blur',@handle_survey_events)
    $(@el).find('input[type=checkbox]').bind('change',@handle_checkbox_change)
    
    $(@el).children(".dummy_question_content").click (e) =>
      @show_actual(e)
    $(@el).children('.dummy_question_content').children(".top_level_content").find(".delete_question").click (e) => 
      @delete(e)

    $(@el).children('.dummy_question_content').children(".top_level_content").find(".copy_question").click (e) => 
      @clear_focus()
      @model.save()
      @save_all_changes(e)
    @renderImageUploader()
    @limit_edit() if @survey_frozen
    return this

  make_dirty: =>
    @dirty = true

  make_clean: =>
    @dirty = false

  render_view: =>
    @render()

  clear_focus: =>
    $('input').blur()
    @render()

  allow_identifier: =>
    !(this.model.get('parent_id') || this.model.get('has_multi_record_ancestor'))

  handle_textbox_blur: (event) =>
    input = $(event.target)
    try
      current_element = $(event.target).closest('div.dummy_question') 
      if current_element
        switch $(current_ele).attr('type')
          when 'SingleLineQuestion'
            propertyHash = {}
            propertyHash[input.attr('name')] = input.val()
            @update_model(propertyHash,curr_model) 
            event.stopImmediatePropagation()
          when 'MultilineQuestion'
            propertyHash = {}
            propertyHash[input.attr('name')] = input.val()
            @update_model(propertyHash,curr_model) 
            event.stopImmediatePropagation()
          when 'NumericQuestion'
            propertyHash = {}
            propertyHash[input.attr('name')] = input.val()
            @update_model(propertyHash,curr_model) 
            event.stopImmediatePropagation()
          when 'DateQuestion'
            propertyHash = {}
            propertyHash[input.attr('name')] = input.val()
            @update_model(propertyHash,curr_model) 
            event.stopImmediatePropagation()
          when 'PhotoQuestion'
            propertyHash = {}
            propertyHash[input.attr('name')] = input.val()
            @update_model(propertyHash,curr_model) 
            event.stopImmediatePropagation()
          when 'RatingQuestion' 
            propertyHash = {}
            propertyHash[input.attr('name')] = input.val()
            @update_model(propertyHash,curr_model) 
            event.stopImmediatePropagation()     
    catch e
      current_element = null 

  search_model_with_id: (model,id,input,event) =>
    if model.sub_question_models
      models = model['sub_question_models']
      _.each(models,(model,index)=>
          if parseInt(model.id) == parseInt(id)
            propertyHash = {}
            propertyHash[input.attr('name')] = input.val()
            @update_model(propertyHash,model)
            event.stopImmediatePropagation()
            return model
          if model.attributes.elements
            _.each(model.sub_question_models,(sub_model,index)=>
                if sub_model.sub_question_models
                  @search_model_with_id(sub_model,id,input,event)
            )
      )

  search_model_with_id_check_box: (model,id,input) =>
    if model.sub_question_models
      models = model['sub_question_models']
      _.each(models,(model,index)=>
          if parseInt(model.id) == parseInt(id)
            propertyHash = {}
            propertyHash[input.attr('name')] = input.is(':checked')
            @update_model(propertyHash,model)
            event.stopImmediatePropagation()
          if model.attributes.elements
            _.each(model.sub_question_models,(sub_model,index)=>
                if sub_model.sub_question_models
                  @search_model_with_id(sub_model,id,input)
            )
      )
  
  handle_checkbox_change: (event) =>
    input = $(event.target)
    this.model.on('change', this.render)
    propertyHash = {}
    propertyHash[input.attr('name')] = input.is(':checked')
    @update_model(propertyHash)
    event.stopImmediatePropagation()

  typingTimer = undefined
  doneTypingInterval = 500
  
  handle_textbox_keyup: (event) =>
    eventInside = event
    clearTimeout typingTimer
    typingTimer = setTimeout(((eventInside)=>
      @handle_survey_events(event)
    ),doneTypingInterval)
    return

  handle_element_blur: (event) =>
    clearTimeout typingTimer
    @handle_survey_events(event)

  handle_element_mouseout: (event) =>
    eventInside = event
    setTimeout(((eventInside)=>
      @handle_survey_events(event)
    ),500)
    return

  handle_survey_events: (event) =>
    input = $(event.target)
    current_ele = $(event.target).closest('div.dummy_question') 
    current_cat = $(event.target).closest('div.dummy_category')
    has_parent_id = $(current_ele).attr('parent_id')
    has_category_id = $(current_ele).attr('category_id') || $(current_cat).attr('category_id')
    is_inside_option = $(current_ele).closest('.option')
    question_type = $(current_ele).attr('type') || $(current_cat).attr('type')
    
    if ( current_ele && ( has_category_id == undefined )  && is_inside_option  && ( has_parent_id == undefined ) )
      propertyHash = {}
      propertyHash[input.attr('name')] = input.val()
      this.model.off('change', this.render)
      @update_model(propertyHash) 
      event.stopImmediatePropagation()
    else if ( current_ele && ( has_category_id == undefined )  && ( has_parent_id == undefined ) )
      propertyHash = {}
      propertyHash[input.attr('name')] = input.val()
      this.model.off('change', this.render)
      @update_model(propertyHash) 
      event.stopImmediatePropagation()
    else if ( has_category_id )
      models = window.questions_models
      cur_element = $(event.target).closest('surveyquestion')
      if cur_element[0]?
        id__ = cur_element[0]['id']
      executed = false
      _.each(models, (num,index) =>
          if (parseInt(num.id) == parseInt(id__))
            if (executed is false)
              curr_model = num
              executed = true
              propertyHash = {}
              propertyHash[input.attr('name')] = input.val()
              this.model.off('change', this.render)
              @update_model(propertyHash,curr_model)
              event.stopImmediatePropagation()
      )
    else if ( has_parent_id )
      models = window.questions_models
      cur_element = $(event.target).closest('surveyquestion')
      if cur_element[0]?
        id__ = cur_element[0]['id']
      _.each(models, (num,index) =>
        if (parseInt(num.id) == parseInt(id__))
          curr_model = num
          propertyHash = {}
          propertyHash[input.attr('name')] = input.val()
          this.model.off('change', this.render)
          @update_model(propertyHash,curr_model)
          event.stopImmediatePropagation()
      )
    return
    
  update_model: (propertyHash,curr_model) =>
    if curr_model
      curr_model.set(propertyHash)
    else
      @model.set(propertyHash)

  renderImageUploader: =>
    loading_overlay = new SurveyBuilder.Views.LoadingOverlayView
    $(this.el).children('.dummy_question_content').children(".top_level_content").children(".question-row").children(".question-container").find(".fileupload").fileupload
      dataType: "json"
      url: @model.image_upload_url()
      submit: =>
        loading_overlay.show_overlay(I18n.t("js.uploading_image"))
      done: (e, data) =>
        this.model.set('image', { thumb: { url: data.result.image_url }})
        loading_overlay.hide_overlay()
        @renderImageUploader()
        @render()

  hide : =>
    $(this.el).hide()

  show: =>
    $(this.el).show()
    first_input = $($(this.el).find('input:text'))[0]
    $(first_input).select()

  limit_edit: =>
    $(this.el).find("input[name=mandatory]").parent('div').hide()
    if @model.get("finalized")
      $(this.el).find("input[name=max_length]").parent('div').hide()
      $(this.el).find("input[name=max_value]").parent('div').hide()
      $(this.el).find("input[name=min_value]").parent('div').hide()
      $(this.el).find(".copy_question").remove()
      $(this.el).find(".delete_question").remove()

  delete: =>
    @model.destroy()

  show_actual: (event) =>
    $(@el).children('.dummy_question_content').addClass("active")

  unfocus: =>
    $(@el).children('.dummy_question_content').removeClass("active")

  set_order_number: (last_order_number) =>
    index = $(@el).index() + 1
    @model.set({order_number: last_order_number + (index * @ORDER_NUMBER_STEP)})
    index

  reset_question_number: =>
    index = $(@el).index()
    @model.question_number = index + 1

  reset_sub_question_numbers: =>
    _(@sub_questions).each (sub_question) =>
      index = $(sub_question.el).index()
      sub_question.model.question_number = @model.question_number + '.' + (index + 1)
      sub_question.reset_sub_question_numbers() if sub_question.can_have_sub_questions
    @render()

  save_all_changes: =>
    $(@el).trigger("copy_question.save_all_changes", this)

  copy_question: =>
    $(@el).children('.dummy_question_content').children(".top_level_content").children(".copy_question_hidden").click()  
    