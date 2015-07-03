class CorporateWebsController < ApplicationController
  layout "corporate"
  def index
    
  end

  def about
  end

  def send_brochure
  #render :text => params[:enquiry] and return false

    @enquiry = BrochureEnquiry.find_by_email(params[:enquiry][:email])
    begin
      if @enquiry.present?
        count = @enquiry.count + 1;
        @enquiry.update_attributes(:count => count) 
      else
        @enquiry = BrochureEnquiry.create!(params[:enquiry].merge(:count => 1))
      end
        PrivacyMailer.lumstic_brochure(@enquiry.email).deliver 
        redirect_to :action => "about"
    rescue => e  
      flash[:error] = e.message
      p "*****#{flash[:error]}*****"
      redirect_to :action => "about"
    end
  end

  def partners
  end

  def login
  end

  def contact
  end
end
