class SurveyApp.UserOptions
	constructor: (@container) ->
		@user_options = @container.find(".profilePopUp")
		@container.click(@user_options_toggle)

	user_options_toggle: =>
		@user_options.fadeToggle 300

	hide_options: =>
		@user_options.fadeOut 300
