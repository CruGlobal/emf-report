Rails.application.routes.draw do
  resources :stats, only: [:index, :show]
end
