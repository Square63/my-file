Wall::Application.routes.draw do

  post "/upload" => "uploads#nginx_proxy", as: :nginx_proxy
  get "D:id" => "uploads#show", as: :download
  get "F:id" => "items#show", as: :special_folder

  devise_for :users
  resources :uploads
  resources :folders
  resources :items

  root "items#index"

end
