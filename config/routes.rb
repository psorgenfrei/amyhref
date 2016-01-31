Rails.application.routes.draw do
  root 'home#index'

  namespace :admin do
    resources :hrefs do
      post 'train_good', :as => :train_good_path
      post 'train_bad', :as => :train_bad_path
    end
  end
end
