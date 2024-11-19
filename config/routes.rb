Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :customers
      resources :loan_simulators
    end
  end
end