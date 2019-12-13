Rails.application.routes.draw do
  get '/status', to: 'certs#index'
  post '/domain', to: 'certs#create'
  mount Sidekiq::Web => '/sidekiq'
end
