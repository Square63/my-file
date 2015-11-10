Wall::Application.routes.draw do

  devise_for :users
  resources :files

  post "/upload" => "files#nginx"

  root "files#new"

end
