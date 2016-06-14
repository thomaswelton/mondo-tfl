Rails.application.routes.draw do
  root to: 'sessions#new'

  get    '/auth/:provider/callback', to: 'sessions#create'
  get    '/auth/failure',            to: 'sessions#auth_failure'
  get    '/receipt/:date',           to: 'receipts#show'
  get    '/tips',                    to: 'tips#index'
  get    '/tips/:tip',               to: 'tips#show', as: :tip
  delete '/logout',                  to: 'sessions#destroy'

  resources :users
end
