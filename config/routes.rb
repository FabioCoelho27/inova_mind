Rails.application.routes.draw do
  get 'quotes/:tag', to:'quotes#quotes'
  get 'quotes', to: 'quotes#index'
  post 'quotes/clean', to: 'quotes#clean_all'
  post 'quotes/:tag/clean', to: 'quotes#clean'
  post 'quotes/:tag/reset', to: 'quotes#reset'
  post 'user/signup'
  post 'user/login'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
