Rails.application.routes.draw do

  mount Ckeditor::Engine => "/ckeditor"

  match "/404", :to => "errors#not_found", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all

  if Rails.env.development? || Rails.env.staging?
    get "/sandbox" => "sandbox#index"
    get "/sandbox/*template" => "sandbox#show"
  end

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  draw :custom
  draw :account
  draw :admin
  draw :annotation
  draw :budget
  draw :comment
  draw :community
  draw :debate
  draw :devise
  draw :direct_upload
  draw :document
  draw :graphql
  draw :legislation
  draw :management
  draw :moderation
  draw :notification
  draw :officing
  draw :poll
  draw :proposal
  draw :related_content
  draw :tag
  draw :user
  draw :valuation
  draw :verification
  draw :sures

  root "welcome#index"
  get "/welcome", to: "welcome#welcome"
  get "/conectados", to: "welcome#encuentrosconexpertos"
  get '/update_padron' => 'users#update_padron', as: :update_padron
  get "/eventos", to: "welcome#eventos"  
  get "/semana-administracion-abierta", to: "welcome#agend_admin" 

  get "/madridsalealbalcon" => redirect("/legislation/processes/#{Rails.application.secrets.id}")
  get "/compartimosbarrio" => redirect("/legislation/processes/#{Rails.application.secrets.id_barrio}")
  get "/reto-compartimos-barrio" => redirect("legislation/processes/#{Rails.application.secrets.id_reto_compartimos_barrio}/proposals")
  
  get "/consul.json", to: "installation#details"
  
  resources :stats, only: [:index]
  resources :images, only: [:destroy]
  resources :documents, only: [:destroy]
  resources :follows, only: [:create, :destroy]

  # More info pages

  ### Modified in: config/routes/custom.rb

  ### ToDo: Figure out a way to maintain Consul's routes in this file,
  #         whilst modifying them in routes/custom.rb
  #         The main problem here is that we are using the same `as` value
  ###
  # get 'help',             to: 'pages#show', id: 'help/index',             as: 'help'
  # get 'help/how-to-use',  to: 'pages#show', id: 'help/how_to_use/index',  as: 'how_to_use'
  # get 'help/faq',         to: 'pages#show', id: 'help/faq/index',         as: 'faq'

  # Static pages
  resources :pages, path: "/", only: [:show]

  resources :double_confirmations do
    get :no_phone, on: :collection
    get :user_blocked, on: :collection
    get :request_access_key, on: :collection
    get :new_password_sent, on: :collection
    post :request_post_access_key, on: :collection
  end

  get "*missing" => redirect('/') 
end
