Rails.application.routes.draw do
  root 'home#index'

  namespace :admin do
    resources :hrefs do
      post :train, :as => :train_path
      collection do
        get :today
      end
      collection do
        get :yesterday
      end
    end
  end
end
