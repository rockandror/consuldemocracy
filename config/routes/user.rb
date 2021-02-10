resources :users, only: [:show, :edit, :update] do
  post :edit
  post :update
  resources :direct_messages, only: [:new, :create, :show]
end
