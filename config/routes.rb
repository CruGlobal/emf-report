Rails.application.routes.draw do
  resources :stats, only: [:index] do
    get :weekly
    get :monthly
  end
end
