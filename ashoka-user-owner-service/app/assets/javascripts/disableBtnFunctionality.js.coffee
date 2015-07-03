class UserOwner.disableBtn
	constructor: (@container) ->
		@Field = @container.find('input[type="text"]')
		@FieldArea = @container.find('textarea')
		@cancelBtn = @container.find('input[type="reset"]')
		@saveBtn = @container.find('input[type="submit"]')
		@logoUpload = @container.find('input[type="file"]')
		@cancelBtn.css('cursor' , 'default')

		@Field.keypress(@activation)
		#@Field.blur(@deactivate)
		@FieldArea.keypress(@activation)
		#@FieldArea.blur(@deactivate)
		@logoUpload.change(@activation)
	
	activation: =>	
		#console.log "working"
		#@cancelBtn.removeClass('disabled')
		@cancelBtn.removeAttr('disabled')
		@saveBtn.removeAttr('disabled')
		#@cancelBtn.attr('href' , '/')
		#@cancelBtn.css('cursor' , 'pointer')
		
	
	#deactivate: =>	
		#console.log "notWorking"
		#@cancelBtn.addClass('disabled')	
		#@saveBtn.addClass('disabled')		
		#@saveBtn.attr('disabled' , 'disabled')
	