Rails.application.routes.draw do
  resources :lunches, only: [:index]
  post 'lunches/upload', to: 'lunches#upload'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
