Rails.application.routes.draw do
  root 'home#index'

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
  get '*archives' => 'home#archives'
end
