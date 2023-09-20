resources :debates do
  member do
    put :flag
    put :unflag
    put :mark_featured
    put :unmark_featured
  end

  resources :votes, controller: "debates/votes", only: [:create, :destroy]

  collection do
    get :suggest
    put "recommendations/disable", only: :index, controller: "debates", action: :disable_recommendations
  end
end
