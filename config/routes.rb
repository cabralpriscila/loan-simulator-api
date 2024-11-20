Rails.application.routes.draw do
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
