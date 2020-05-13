resources :communities, only: [:show] do
  resources :topics do
    member do
      post :vote
    end
  end
end
