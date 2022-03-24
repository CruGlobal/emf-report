Rails.application.routes.draw do
  resources :stats, only: [:index] do
    get :weekly
    get :monthly
    get :group_score_card
  end

  get "login", to: "login#create"
  get "login/callback", to: "login#callback"
  get "auth/oktaoauth/callback", to: "login#callback"
  get "login/clear", to: "login#clear"
  get "login/error", to: "login#error"

  root to: redirect("/stats")
end
