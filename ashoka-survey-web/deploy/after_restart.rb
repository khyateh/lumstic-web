run "RAILS_ENV=#{environment} #{current_path}/script/delayed_job stop"
run "RAILS_ENV=#{environment} #{current_path}/script/delayed_job --queues=survey_duplication,generate_excel,mixpanel -n 3 start"
