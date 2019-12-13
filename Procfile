web: bundle exec puma -p $PORT
worker: bundle exec sidekiq -C config/sidekiq.yml | tee ./log/sidekiq.log
#urgentworker:  bundle exec whenever --update-crontab
