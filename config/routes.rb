Wall::Application.routes.draw do

  resources :files do
    collection do
      get :upload
      post :upload
    end
  end

end
