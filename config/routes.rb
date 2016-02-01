Rails.application.routes.draw do
  root 'home#index'

  namespace :admin do
    resources :hrefs do
      post :train, :as => :train_path
    end
  end
end
