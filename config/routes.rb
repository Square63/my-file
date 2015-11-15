Wall::Application.routes.draw do

  devise_for :users
  resources :uploads

  post "/upload" => "uploads#nginx_proxy"
  get "F:id" => "uploads#show", as: :download

  root "uploads#index"

end
