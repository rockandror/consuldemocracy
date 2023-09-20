resources :comments, only: [:create, :show], shallow: true do
  member do
    put :flag
    put :unflag
    put :hide
  end

  resources :votes, controller: "comments/votes", only: :create, shallow: false
end
