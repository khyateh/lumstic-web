# class PrivacyMailer < ActionMailer::Base
#  default from: "no-reply@lumstic.com"

#  def deactivation_mail(organization, users)
#    @organization_name = organization.name
#    headers['X-SMTPAPI'] = JSON.generate(:category => ENV['SENDGRID_CATEGORY'])
#    mail(:bcc => users.map(&:email),
#         :subject => I18n.t("privacy_mailer.deactivation_mail.subject", :organization_name => @organization_name))
#  end

#  def lumstic_brochure(email)
#  	@enquiry = BrochureEnquiry.find_by_email(email)
#    attachments['LumStic.pdf'] = File.read("#{Rails.root}/public/LumStic.pdf")
#  	mail(:to => @enquiry.email ,:bcc => @enquiry.email, :subject => "Lumstic Request Note")
#  end
#end
