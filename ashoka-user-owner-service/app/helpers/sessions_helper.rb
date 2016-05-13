module SessionsHelper
	def application_url(redirect_uri)
		url = URI(redirect_uri)
		url.scheme + "://" + url.host + ":" + url.port.to_s
	end
end
