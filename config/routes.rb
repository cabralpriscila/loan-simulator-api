require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  
  mount Sidekiq::Web => '/sidekiq' if Rails.env.development?
  
  namespace :api do
    namespace :v1 do
      resources :customers
      resources :loan_simulators do
        member do
          patch :update_status
        end
      end
    end
  end
end
