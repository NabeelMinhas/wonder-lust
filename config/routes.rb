Rails.application.routes.draw do
  # Client Dashboard Routes
  root "dashboard#index"

  resources :projects, only: [ :index, :create, :show ] do
    collection do
      get :order_new
      post :process_payment
    end
    
    member do
      get :view_footage
    end
  end

  resources :video_types, only: [ :index ]
end
