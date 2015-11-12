Wall::Application.routes.draw do

  devise_for :users
  resources :uploads

  post "/upload" => "uploads#nginx_proxy"

  root "uploads#index"

end
