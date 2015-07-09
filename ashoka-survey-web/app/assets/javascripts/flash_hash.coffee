class SurveyApp.FlashHash
  constructor: (@container) ->
  	@message = @container.find(".flash")
  	setTimeout @vanish, 3000
	
  vanish: =>
  	@message.fadeOut 1000
