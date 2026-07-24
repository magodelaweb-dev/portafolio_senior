Rails.application.routes.draw do
  # The site answers on both the apex and the www hostname; redirect the latter to the
  # former so a page has a single canonical URL. Matched before every other route so it
  # applies to the whole site, path and query string included.
  match "(*path)", to: redirect(host: "magodelaweb.com"), via: :all,
    constraints: { host: "www.magodelaweb.com" }

  resource :session
  resources :passwords, param: :token
  resources :projects

  get "about" => "static_pages#about", as: :about

  # Live operations dashboard ("the app alive").
  get "ops" => "ops#index", as: :ops
  get "monitoreo" => redirect("/ops")
  get "ops/metrics" => "ops#metrics", as: :ops_metrics
  post "ops/enqueue" => "ops#enqueue", as: :ops_enqueue
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "projects#index"
end
