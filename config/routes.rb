Rails.application.routes.draw do
  # Direct routes without API namespace
  namespace :auth do
    post :signup
    post :signin
  end
  
  resources :users, only: [:index]
  
  # 채팅 관련 라우트
  post 'chat/session', to: 'chat#create_session'
  get 'chat/:room_id/messages', to: 'chat#messages'
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Root route - return 404 for non-API requests
  root to: proc { [200, {}, ['Wellcome to Hoom!']] }

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
