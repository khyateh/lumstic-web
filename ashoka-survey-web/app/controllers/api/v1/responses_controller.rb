
module Api::V1
  class ResponsesController < APIApplicationController
 #   load_resource :survey, :only => [:index, :show, :count]
 #   load_resource :through => :survey, :only => [:show, :count]
    authorize_resource

    skip_before_action :verify_authenticity_token, only: [:create, :update]

    before_filter :read_params, :decode_base64_images, :convert_to_datetime, :only => [:create, :update]
    before_filter :require_response_to_not_exist, :only => :create

    def read_params
        require 'json'
        @@body =  JSON.parse(request.body.read)        
	      @@resp = @@body["response"]        
        @@resp["ip_address"]  = request.remote_ip
    end

    def count
      render :json => { count: @responses.count }
    end

    def create
      response = Response.new
      if response.create_response(@@resp.except("access_token"))
	render :json => response.to_json_with_answers_and_choices
      else
        render :json => response.to_json_with_answers_and_choices, :status => :bad_request
#        Airbrake.notify(ActiveRecord::RecordInvalid.new(response))
      end
    end

    def update
      response = Response.find_by_id(@@resp[:id])
      return render :nothing => true, :status => :gone if response.nil?
      response.update_response_with_conflict_resolution(@@resp)
      response.update_records # TODO: Refactor this into the model method, if possible

      if response.invalid?
        render :json => response.to_json_with_answers_and_choices, :status => :bad_request
        Airbrake.notify(ActiveRecord::RecordInvalid.new(response))
      else
        render :json => response.to_json_with_answers_and_choices
      end
    end

    def incomplete
      response = Response.find_incomplete_by_surveyid(params[:id])
      render :json => response.as_json(:include => :answers)
    end

    def show
      response = Response.find_by_surveyid(params[:id])
      render :json => response.as_json(:include => :answers)
    end

    private

    def decode_base64_images
      answers_attributes = @@resp['answers_attributes'] || []
      answers_attributes.each do |_, answer|
        if answer.has_key? 'photo'
          sio = StringIO.new(Base64.decode64(answer['photo']))
          sio.class.class_eval { attr_accessor :content_type, :original_filename } # Need to do this to pass Paperclip's content_type validation. Found this at http://stackoverflow.com/questions/5054982/rails3-problem-saving-base64-image-with-paperclip
          sio.content_type = 'image/jpeg'
          sio.original_filename = "photo_#{SecureRandom.hex}.jpeg"
          answer['photo'] = sio
        end
      end
    end

    def convert_to_datetime
      answers_attributes = @@resp["answers_attributes"]

      answers_attributes.each do |key, answer_attributes|
        answer_attributes["updated_at"] = Time.at(answer_attributes["updated_at"].to_i).strftime("%Y%jT%H%M%S")
      end unless answers_attributes.blank?

      @@resp["updated_at"] = Time.at(@@resp["updated_at"].to_i).strftime("%Y%jT%H%M%S") unless @@resp.nil?
    end

    def require_response_to_not_exist
      if @@resp[:mobile_id]
        response = Response.find_by_mobile_id(@@resp[:mobile_id])
        if response
          render :json => response.to_json_with_answers_and_choices
        end
      end
    end
  end
end
