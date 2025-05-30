Rails.application.routes.draw do
  devise_for :users

  authenticated :user do
    root "resumes#new", as: :authenticated_root
  end

  root "home#index"

  resources :resumes, only: [ :create, :show ] do
    member do
      post :save_candidate
    end
  end

  resources :saved_candidates, only: [ :index, :destroy ]
end
