Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post 'bookings', to: 'bookings#create'
  get 'bookings', to: 'bookings#index'
  post 'bookings/:id/start', to: 'bookings#start'
  post 'bookings/:id/end', to: 'bookings#end'

  post 'users', to: 'users#create'
  post 'auth', to: 'auth#create'
end
