module ApplicationHelper
	def format_flash_message(message)
		message.is_a?(Array) ? message.join("\n") : message
	end
	
	def apps
		applications = Doorkeeper::Application.all
		applications
	end

	def current_class?(test_path)
    return 'active' if request.path == test_path
    ''
  	end

  	def current_newsted_class?(path)
  	return 'active' if request.path.include? path.to_s
  	''
  	end

end
