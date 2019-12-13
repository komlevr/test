  require 'sidekiq'
  require 'sidekiq/web'
  
  Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
    [user, password] == [ENV['USERNAME'], ENV['PASSWD']]
  end
