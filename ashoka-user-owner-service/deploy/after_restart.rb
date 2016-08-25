run "RAILS_ENV=#{environment} #{current_path}/script/delayed_job stop"
run "RAILS_ENV=#{environment} #{current_path}/script/delayed_job --queues=organization_activation_mail,organization_deactivation_mail,password_reset_mail,allow_sharing_email, -n 3 start"
