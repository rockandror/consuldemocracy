# Add here routes for custom features
get "contact", to: "contact#new", as: "new_contact"
post "contact", to: "contact#create", as: "contact"

namespace :admin do
  namespace :cookies do
    resources :vendors, except: [:index]
  end
end
