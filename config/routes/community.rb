resources :communities, only: [:show] do
  resources :topics do
    member do
      post :vote
      get :vote, action: :newsletter_vote
    end
  end
end
