Wall::Application.routes.draw do

  resources :files

  root "files#new"

end
