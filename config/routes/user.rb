resources :users, only: [:show] do
  resources :direct_messages, only: [:new, :create, :show]

  member do
    get '/comments/:comment_id/edit', to: "users#edit_comment", as: "edit_comment"
  end
end
