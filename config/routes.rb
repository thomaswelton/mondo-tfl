Rails.application.routes.draw do
  root to: 'sessions#new'
  get    '/auth/:provider/callback', to: 'sessions#create'
  get    '/receipt/:date',           to: 'receipts#show'
  delete '/logout',                  to: 'sessions#destroy'

  resources :users
end
