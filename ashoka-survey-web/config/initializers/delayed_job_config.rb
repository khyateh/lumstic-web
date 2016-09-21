# Calls to Rails.logger go to the same object as Delayed::Worker.logger
Delayed::Worker.logger = Rails.logger
Delayed::Worker.sleep_delay = ENV['DELAYED_WORKER_SLEEP_DELAY'] || Delayed::Worker.sleep_delay