class UserOwner.BackBtn
	constructor: (@container) ->
		@back_btn = @container.find(".backBtn")
		@back_btn.click(@go_back)
	go_back: =>
		window.history.back()
		return false		
