class UserOwner.AppFlashHash
  constructor: (@container) ->
  	# console.log @container
  	@message = @container.find(".flash")
  	# console.log @message
  	setTimeout @vanish, 3000
	
  vanish: =>
  	@message.fadeOut 1000
