RailsSkeleton::Application.routes.draw do

  resources :transactions do
    member do
      get "/update", as: "update", to: "transactions#update"
      get "/destroy", as: "destroy", to: "transactions#destroy"
    end
  end

  root to: "transactions#index"

end
