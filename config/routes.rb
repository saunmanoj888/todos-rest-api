Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :todos do
    resources :items, shallow: true do
      put 'update_checked', on: :member
    end
  end

  resources :users
  post "/login", to: "users#login"
  get "/auto_login", to: "users#auto_login"
  get 'all_items', to: 'items#all_items'
end
