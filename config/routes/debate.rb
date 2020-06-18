resources :debates do
  member do
    post :new_borought
    post :vote
    put :flag
    put :unflag
    put :mark_featured
    put :unmark_featured
  end

  collection do
    post :new_borought
    get :borought
    get :map
    get :suggest
    put "recommendations/disable", only: :index, controller: "debates", action: :disable_recommendations
  end
end
