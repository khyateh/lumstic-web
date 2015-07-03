SurveyBuilder.Views.Dummies ||= {}

# Represents a dummy question on the DOM
class SurveyBuilder.Views.Dummies.QuestionView extends Backbone.View
  ORDER_NUMBER_STEP: 2

  # events:
  #   'blur  input[type=text]': 'handle_textbox_keyup'
  #   'change input[type=number]': 'handle_textbox_keyup'
  #   'change input[type=checkbox]': 'handle_checkbox_change'

  initialize: (@model, @template, @survey_frozen) =>
    # console.log "Dummies.QuestionView initialize"
    @model.dummy_view  = this
    @can_have_sub_questions = true
    @model.on('change', @render, this)
    @model.on('keyup', @render, this)
    @model.on('mouseout', @render, this)
    @model.on('change:errors', @render, this)
    @model.on('save:completed', @renderImageUploader, this)
    @model.on('change:id', @render, this)

  render: =>
    # console.log "Dummies.QuestionView render "
    $(@el).html('<div class="dummy_question_content"><div class="top_level_content"></div></div>') if $(@el).is(':empty')
    @model.set('content', I18n.t('js.untitled_question')) if _.isEmpty(@model.get('content'))
    json = _.extend(@model.toJSON())
    data = _.extend(@model.toJSON().question, {errors: @model.errors, image_url: @model.get('image_url')})
    data = _(data).extend({question_number: @model.question_number})
    data = _(data).extend({duplicate_url: @model.duplicate_url()})
    data = _(data).extend({image_upload_url: @model.image_upload_url()})
    ####################################################
    data.question = _.extend(@model.toJSON().question)
    data.allow_identifier = @allow_identifier()
    # console.dir data
    ####################################################
    $(@el).children('.dummy_question_content').children(".top_level_content").html(Mustache.render(@template, data))
    $(@el).addClass("dummy_question")
    $(@el).find('abbr').show() if @model.get('mandatory')
    $(@el).find('.star').raty({
      readOnly: true,
      number: @model.get('max_length') || 5
    })
    # #####################################################
    $(@el).find('input[type=text]').bind('keyup',@handle_textbox_keyup)      
    $(@el).find('input[type=number]').bind('keyup',@handle_textbox_keyup)
    $(@el).find('input[type=number]').bind('mouseout',@handle_element_mouseout)
    $(@el).find('input[type=checkbox]').bind('change',@handle_checkbox_change)
    
    typingTextTimer = undefined
    typingTextInterval = 1500
    this.$('input[type=text]').keyup =>
      clearTimeout typingTextTimer
      typingTextTimer = setTimeout((=>
        setTimeout (=>
          text_value = this.$('input[type=text]').val()
          update_input_value = $('[value="' + text_value + '"]')
          this.$(update_input_value).focus().val ""  unless text_value is ""
          this.$(update_input_value).focus().val text_value
        ), 200
      ),typingTextInterval)
      return

    typingNumberTimer = undefined
    typingNumberInterval = 1500
    this.$('input[type=number]').keyup =>
      clearTimeout typingTextTimer
      typingNumberTimer = setTimeout((=>
        setTimeout (=>
          number_value = this.$('input[type=number]').val()
          update_input_value = $('[value="' + number_value + '"]')
          this.$(update_input_value).focus().val ""  unless number_value is ""
          this.$(update_input_value).focus().val number_value
        ), 200
      ),typingNumberInterval)
      return

    $(@el).children(".dummy_question_content").click (e) =>
      # $(@el).css({'z-index':'5'})
      # $(@el).css({'border':'1px solid red'})
      # $(@el).css({'box-shadow':'-1px 4px 30px rgba(0, 0, 0, 0.5)' ,'-webkit-box-shadow':'-1px 4px 30px rgba(0, 0, 0, 0.5)' ,'-moz-box-shadow':'-1px 4px 30px rgba(0, 0, 0, 0.5)'})
      @show_actual(e)

    $(@el).children('.dummy_question_content').children(".top_level_content").find(".delete_question").click (e) => 
      @delete(e)

    $(@el).children('.dummy_question_content').children(".top_level_content").find(".copy_question").click (e) => 
      @model.save()
      @save_all_changes(e)
    ##################################
    @renderImageUploader()
    ##################################
    @limit_edit() if @survey_frozen
    return this

  make_dirty: =>
    @dirty = true

  make_clean: =>
    @dirty = false

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
      console.log "[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[["
      console.log "Searching for ID = " + id 
      console.log "Inside"
      console.dir model
      models = model['sub_question_models']
      _.each(models,(model,index)=>
          console.log "current model is " 
          console.dir model
          console.log "current model's id is " 
          console.log model.id 
          if parseInt(model.id) == parseInt(id)
            propertyHash = {}
            propertyHash[input.attr('name')] = input.val()
            # this.model.on('change', this.render)
            @update_model(propertyHash,model)
            event.stopImmediatePropagation()
            return model
          if model.attributes.elements
            _.each(model.sub_question_models,(sub_model,index)=>
                if sub_model.sub_question_models
                  @search_model_with_id(sub_model,id,input,event)
            )
      )
      console.log "]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]"

  search_model_with_id_check_box: (model,id,input) =>
    if model.sub_question_models
      console.log "[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[["
      console.log "Searching for ID = " + id 
      console.log "Inside"
      console.dir model
      models = model['sub_question_models']
      _.each(models,(model,index)=>
          console.log "current model is " 
          console.dir model
          console.log "current model's id is " 
          console.log model.id 
          if parseInt(model.id) == parseInt(id)
            propertyHash = {}
            propertyHash[input.attr('name')] = input.is(':checked')
            # this.model.on('change', this.render)
            @update_model(propertyHash,model)
            event.stopImmediatePropagation()
            # return model
          if model.attributes.elements
            _.each(model.sub_question_models,(sub_model,index)=>
                if sub_model.sub_question_models
                  @search_model_with_id(sub_model,id,input)
            )
      )
      console.log "]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]"
  
  handle_checkbox_change: (event) =>
    # @model.off('change', this.render)
    # input = $(event.target)
    # current_ele = $(event.target).closest('div.dummy_question') 
    # current_cat = $(event.target).closest('div.dummy_category')
    # console.log "current_cat"
    # console.dir current_cat
    # console.log "====================="
    # console.log "current_ele"
    # console.dir current_ele
    # console.dir  $(current_ele).attr('parent_id')

    # has_parent_id = $(current_ele).attr('parent_id')
    # has_category_id = $(current_ele).attr('category_id') || $(current_cat).attr('category_id')
    # console.log "====================="
    # console.log "=====================" 
    # console.dir has_category_id

    # if ( current_ele && ( has_category_id == undefined )  )
    #   console.log "Main level question"
    #   propertyHash = {}
    #   propertyHash[input.attr('name')] = input.is(':checked')
    #   @update_model(propertyHash,curr_model) 
    #   event.stopImmediatePropagation()
    # else if ( has_category_id )
    #   console.log " has_category_id "
    #   console.log "====sub_question_models===="
    #   models = @model['sub_question_models']
    #   console.dir models
    #   cur_element = $(event.target).closest('surveyquestion');
    #   id__ = cur_element[0]['id']
    #   console.log "id__ is " + id__
    #   @search_model_with_id_check_box(@model,id__,input)
    #   # console.log "foundmodel"
    #   # console.dir foundmodel
    #   _.each(models, (num,index) => 
    #       if num.attributes.elements
    #         console.log "++++sub_question_models++++"
    #         console.dir num.sub_question_models
    #         _.each(num.sub_question_models, (sub_model,index) => 
    #           console.dir sub_model
    #           if (parseInt(sub_model.id) == parseInt(id__))
    #             console.log "++++++++TRUE+++++++++++"
    #             # curr_index = index
    #             curr_model = sub_model
    #             console.dir curr_model
    #             propertyHash = {}
    #             propertyHash[input.attr('name')] = input.is(':checked')
    #             # this.model.on('change', this.render)
    #             @update_model(propertyHash,sub_model)
    #             event.stopImmediatePropagation()
    #         )
    #       console.log "++++++++++"
    #       console.dir (num.attributes.elements)
    #       console.log "++++++++++"
    #       console.log " num,index" + num.id  + index
    #       if (parseInt(num.id) == parseInt(id__))
    #         console.log "TRUE"
    #         # curr_index = index
    #         curr_model = num
    #         console.dir curr_model
    #         propertyHash = {}
    #         propertyHash[input.attr('name')] = input.is(':checked')
    #         # this.model.on('change', this.render)
    #         @update_model(propertyHash,curr_model)
    #         event.stopImmediatePropagation()
    #   )
    # else if (has_parent_id)
    #   console.log "has_parent_id"
    #   console.log "Question under options"
    #   current_opt = $(event.target).closest('div.option')
    #   console.dir current_opt
    #   current_opt_elements =  $(current_opt).attr('elements')
    #   console.dir current_opt_elements
    #   # _.each(current_opt_elements,(obj,index)=>
    #   #     console.log "index " + index
    #   #     console.dir obj
    #   # )
    #   # cur_element = $(event.target).closest('div.dummy_question');
    #   # id__ = cur_element[0]['id'] 
    #   propertyHash = {}
    #   propertyHash[input.attr('name')] = input.is(':checked')
    #   # this.model.on('change', this.render)
    #   @update_model(propertyHash,null)
    #   event.stopImmediatePropagation()
    # return
    
    # try
    #   parent_option = $('parent_id=');
    # catch e
    #   console.log e
    #   parent_option = null 

    # console.log "parent_option"
    # console.dir parent_option

    # curr_index = null
    # try
    #   cur_element = $(event.target).closest('div.dummy_question');
    #   curre_survey_ques = $(event.target).closest('surveyquestion');
    #   console.log "curre_survey_ques"
    #   console.dir $(curre_survey_ques).attr('id');
    #   console.log "cur_element is present"
    #   console.dir cur_element
    #   id__ = cur_element[0]['id'] || $(curre_survey_ques).attr('id');
    # catch e
    #   console.log e
    #   cur_element = null
    #   console.log "cur_element is null"
    #   console.dir cur_element
    
    # console.dir @model['sub_question_models']
    # models = @model['sub_question_models']
    # window.curr_model
    # if (curre_survey_ques)  
    #   curr_model = null  
    #   propertyHash = {}
    #   propertyHash[input.attr('name')] = input.is(':checked')
    #   @update_model(propertyHash,curr_model) 
    #   event.stopImmediatePropagation()
    # else if (cur_element)
    #   try
    #     console.log "id__" + id__
    #     # curr_model = models[0] 
    #     # curr_model = _.find( models , -> (obj) return obj.id = id__ )
    #     # _.find(models, (obj) ->
    #     #   console.log "CURR OBJ ============"
    #     #   console.dir obj 
    #     #   console.log obj.id 
    #     #   (obj.id == id__) ? window.curr_model = obj : curr_model = null
    #     # )
    #     _.each(models, (num,index) => 
    #       if num.id == id__
    #         curr_index = index
    #         curr_model = num
    #         console.dir curr_model
    #         propertyHash = {}
    #         propertyHash[input.attr('name')] = input.is(':checked')
    #         this.model.on('change', this.render)
    #         @update_model(propertyHash,curr_model)
    #         event.stopImmediatePropagation()
    #       )
    #   catch e
    #     curr_model = null
    # else 
    #   curr_model = null  
    #   propertyHash = {}
    #   propertyHash[input.attr('name')] = input.is(':checked')
    #   @update_model(propertyHash,curr_model) 
    #   event.stopImmediatePropagation()
    # event.stopImmediatePropagation()
    # compare:(element, index, list) ->
    #console.log "compare" + id__
    #window.curr_model = element if element.id == id__
    # alert "and this is one is mine"
    # console.log event
    # this.model.off('change', this.render)
    # # Pervious code without timeout # #
    input = $(event.target)
    propertyHash = {}
    propertyHash[input.attr('name')] = input.is(':checked')
    @update_model(propertyHash)
    event.stopImmediatePropagation()

  handle_element_mouseout: (event) =>
    eventInside = event
    setTimeout(((eventInside)=>
      @handle_survey_events(event)
    ),1500)
    return

  typingTimer = undefined
  doneTypingInterval = 1500
  handle_textbox_keyup: (event) =>
    eventInside = event
    clearTimeout typingTimer
    typingTimer = setTimeout(((eventInside)=>
      @handle_survey_events(event)
    ),doneTypingInterval)
    return

  handle_element_blur: (event) =>
    @handle_survey_events(event)

  handle_survey_events: (event) =>
    console.log ":::::::::::::::::::::::::::::::::::::::::::"
    console.dir this.model.id
    console.log ":::::::::::::::::::::::::::::::::::::::::::"
    input = $(event.target)
    current_ele = $(event.target).closest('div.dummy_question') 
    current_cat = $(event.target).closest('div.dummy_category')
    console.log "current_cat"
    console.dir current_cat
    console.log "====================="
    console.log "current_ele"
    console.dir current_ele
    console.dir  $(current_ele).attr('parent_id')
    has_parent_id = $(current_ele).attr('parent_id')
    has_category_id = $(current_ele).attr('category_id') || $(current_cat).attr('category_id')
    is_inside_option = $(current_ele).closest('.option')

    if ( current_ele && ( has_category_id == undefined )  && is_inside_option  && ( has_parent_id == undefined ) )
      console.log "Main level question"
      propertyHash = {}
      propertyHash[input.attr('name')] = input.val()
      @update_model(propertyHash,curr_model) 
      event.stopImmediatePropagation()
    else if ( current_ele && ( has_category_id == undefined )  && ( has_parent_id == undefined ) )
      console.log "Main level question"
      propertyHash = {}
      propertyHash[input.attr('name')] = input.val()
      @update_model(propertyHash,curr_model) 
      event.stopImmediatePropagation()
    else if ( has_category_id )
      console.log " has_category_id "
      console.log "====sub_question_models===="
      models = window.questions_models
      console.dir models
      cur_element = $(event.target).closest('surveyquestion')
      id__ = cur_element[0]['id']
      console.log "id__ is " + id__
      executed = false
      _.each(models, (num,index) =>
          if (parseInt(num.id) == parseInt(id__))
            if (executed is false)
              console.log "TRUE"
              curr_model = num
              console.dir curr_model
              executed = true
              propertyHash = {}
              propertyHash[input.attr('name')] = input.val()
              @update_model(propertyHash,curr_model)
              event.stopImmediatePropagation()
      )
    else if ( has_parent_id )
      console.log "has_parent_id"
      console.log "Question under options"
      current_opt = $(event.target).closest('div.option')
      console.dir current_opt
      current_opt_elements =  $(current_opt).attr('elements')
      console.dir current_opt_elements
      # _.each(current_opt_elements,(obj,index)=>
      #     console.log "index " + index
      #     console.dir obj
      # )
      # cur_element = $(event.target).closest('div.dummy_question');
      # id__ = cur_element[0]['id'] 
      propertyHash = {}
      propertyHash[input.attr('name')] = input.val()
      # this.model.on('change', this.render)
      @update_model(propertyHash,null)
      event.stopImmediatePropagation()
    return
    try 
      parent_option = $('parent_id=');
    catch e
      console.log e
      parent_option = null 
    console.log "parent_option"
    console.dir parent_option
    curr_index = null
    try
      cur_element = $(event.target).closest('div.dummy_question');
      curre_survey_ques = $(event.target).closest('surveyquestion');
      console.log "curre_survey_ques"
      console.dir $(curre_survey_ques).attr('id');
      console.log "cur_element is present"
      console.dir cur_element
      id__ = cur_element[0]['id'] || $(curre_survey_ques).attr('id');
    catch e
      console.log e
      cur_element = null
      console.log "cur_element is null"
      console.dir cur_element
    console.dir @model['sub_question_models']
    models = @model['sub_question_models']
    window.curr_model
    if (curre_survey_ques)  
      curr_model = null  
      propertyHash = {}
      propertyHash[input.attr('name')] = input.val()
      @update_model(propertyHash,curr_model) 
      event.stopImmediatePropagation()
    else if (cur_element)
      try
        console.log "id__" + id__
        # curr_model = models[0] 
        # curr_model = _.find( models , -> (obj) return obj.id = id__ )
        # _.find(models, (obj) ->
        #   console.log "CURR OBJ ============"
        #   console.dir obj 
        #   console.log obj.id 
        #   (obj.id == id__) ? window.curr_model = obj : curr_model = null
        # )
        _.each(models, (num,index) => 
          if num.id == id__
            curr_index = index
            curr_model = num
            console.dir curr_model
            propertyHash = {}
            propertyHash[input.attr('name')] = input.val()
            this.model.on('change', this.render)
            @update_model(propertyHash,curr_model)
            event.stopImmediatePropagation()
          )
      catch e
        curr_model = null
    else 
      curr_model = null  
      propertyHash = {}
      propertyHash[input.attr('name')] = input.val()
      @update_model(propertyHash,curr_model) 
      event.stopImmediatePropagation()
    event.stopImmediatePropagation()
    # compare:(element, index, list) ->
    #console.log "compare" + id__
    #window.curr_model = element if element.id == id__

  update_model: (propertyHash,curr_model) =>
    console.log propertyHash
    if curr_model
      curr_model.set(propertyHash)
      # curr_model.save()
    else
      @model.set(propertyHash)
      # @model.save()
      # $(@el).css({'box-shadow':'0px 0px 0px #000','-webkit-box-shadow':'0px 0px 0px #000' , '-moz-box-shadow':'0px 0px 0px #000'})

  renderImageUploader: =>
    # console.log "renderImageUploader"
    loading_overlay = new SurveyBuilder.Views.LoadingOverlayView
    # console.dir $(this.el).children(".upload_files").children(".fileupload").fileupload 
    $(this.el).children('.dummy_question_content').children(".top_level_content").children(".question-row").children(".question-container").find(".fileupload").fileupload
      dataType: "json"
      url: @model.image_upload_url()
      submit: =>
        loading_overlay.show_overlay(I18n.t("js.uploading_image"))
      done: (e, data) =>
        this.model.set('image', { thumb: { url: data.result.image_url }})
        loading_overlay.hide_overlay()
        @renderImageUploader()


  hide : =>
    console.log "CALLING HIDE"
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
    # $(@el).trigger("dummy_click")
    # console.dir @model
    # @model.actual_view.show()
    # todo : add show hide toggle here
    # $(@el).children('.dummy_question_content').children(".top_level_content").children(".settings-view").hide()
    $(@el).children('.dummy_question_content').addClass("active")

  unfocus: =>
    $(@el).children('.dummy_question_content').removeClass("active")

  set_order_number: (last_order_number) =>
    console.log "set_order_number"
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