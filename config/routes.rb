Rails.application.routes.draw do
  root 'home#index'

  resources :sessions
  get "/auth/:provider/callback" => 'sessions#create'
  delete "/signout" => 'sessions#destroy'

  match '/you(/:page)', :to => 'you#index', :as => 'you', :via => :get
  match '/you/newsletters/:newsletter_id(/:page)', :to => 'you#newsletters', :as => 'you_newsletter', :via => :get

  namespace :admin do
    resources :hrefs do
      post :train, :as => :train_path
      collection do
        get :search
        get :today
        get :yesterday
      end
    end
  end

  #get '*archives' => 'home#archives'
end
