RailsSkeleton::Application.routes.draw do

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

  root to: "transactions#index"

end
