job_type :sidekiq, "cd :path && :environment_variable=:environment bundle exec sidekiq-client push :task :output"

every 1.minutes, :roles => "roman" do #[:app] do
  sidekiq "CheckAllDomainsWorker"
end
