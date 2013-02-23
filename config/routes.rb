RailsSkeleton::Application.routes.draw do

  get "/sign_in", to: "user_sessions#new"
  post "/sign_in", to: "user_sessions#create"
  get "/sign_out", to: "user_sessions#destroy"

  resources :transactions do
    member do
      get "/update", as: "update", to: "transactions#update"
      get "/destroy", as: "destroy", to: "transactions#destroy"
    end
    collection do
      get :update_upcoming_time_window
    end
  end

  resources :recurrences

  resources :accounts do
    member do
      get :edit_balance
      post :update_balance
    end
  end

  resources :users

  root to: "transactions#index"

end
