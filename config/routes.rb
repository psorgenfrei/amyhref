Rails.application.routes.draw do
  root 'home#index'

  resources :sessions, only: :new
  get "/auth/:provider/callback" => 'sessions#create'

  match '/you', :to => 'you#index', :as => 'you'

  namespace :admin do
    resources :hrefs do
      post :train, :as => :train_path
      collection do
        post :search
        get :today
        get :yesterday
      end
    end
  end
  get '*archives' => 'home#archives'
end
