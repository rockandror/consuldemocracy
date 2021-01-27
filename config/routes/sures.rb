resources :sures, only: [:index] do
    get :search, on: :collection
  end