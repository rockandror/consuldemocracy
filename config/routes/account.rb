resource :account, controller: "account", only: [:show, :update, :delete] do
  get :erase, on: :collection

  delete :destroy_avatar, on: :collection
end

resource :subscriptions, only: [:edit, :update]
