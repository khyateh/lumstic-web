class SurveyApp.LanguageSelection
 constructor: (@container) ->
  @lang_selection_popup = @container.find("#lang")
  @current_lang = @container.find("#current_lang")
  @current_lang.click(@lang_selection_toggle)
  @close_btn = @container.find(".close_btn")
  @overlay = @container.next(".overlay")
  @close_btn.click(@hide_lang_selection)
 
 lang_selection_toggle: =>
  @lang_selection_popup.fadeToggle 500
  @overlay.fadeToggle 500
  
 show_lang_selection: =>
  @lang_selection_popup.fadeIn 500
  @overlay.fadeIn 500

 hide_lang_selection: =>
  @lang_selection_popup.fadeOut 500
  @overlay.fadeOut 500
  