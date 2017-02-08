module CorporateWebsHelper
	def page_title

		title = {:index => "Welcome to LumStic",
				 :about => "About us  | LumStic", 
				 :partners => "Partners | LumStic",
				 :contact => "Contact  us  | LumStic",
				 :privacypolicy => "Privacy Policy | LumStic"}

		if title.keys.include?(params[:action].to_sym)
			title[params[:action].to_sym]
		else
			"LumStic"
		end
	end

	def extra_style
		style = ["about","partners","contact","privacypolicy"]
		if style.include?(params[:action])
			true
		else
			false
		end 
	end

	def body_id
		id = {:partners => "aboutus"}
		if id.keys.include?(params[:action].to_sym)
			id[params[:action].to_sym]
		end
	end

	def active_class(param)
		arr = ["index","about","partners","contact", "privacypolicy"]
		"active" if params[:action] == param
	end
end
