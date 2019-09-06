scope module: :verification do
  resource :residence, controller: "residence", only: [:new, :create]
  resource :sms, controller: "sms", only: [:new, :create, :edit, :update]
  resource :verified_user, controller: "verified_user", only: [:show]
  resource :email, controller: "email", only: [:new, :show, :create]
  resource :letter, controller: "letter", only: [:new, :create, :show, :edit, :update]
end

namespace :verification do
  resource :process, controller: "process", only: [:new, :create]
  resource :confirmation, controller: "confirmation", only: [:new, :create]
end

resource :verification, controller: "verification", only: [:show]
