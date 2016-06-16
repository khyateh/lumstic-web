SurveyWeb::Application.routes.draw do
  resources :respondents, :only => [:index, :update, :update_bulk] do
    post 'update_bulk', :on => :collection
  end
  get "corporate_webs/index"
  get "/about-us" => "corporate_webs#about"
  get "/partners" => "corporate_webs#partners"
  get "/contact-us" => "corporate_webs#contact"
  get "/send_brochure" => "corporate_webs#send_brochure"  

  get "/help" => "help#index" 

  get "pages/index"

  get "pages/dummy"

  scope "(:locale)", :locale => /#{I18n.available_locales.join('|')}/ do
  get '/auth/user_owner/callback' => 'sessions#create'
  post '/auth/failure' => 'sessions#failure'
  get '/logout' => 'sessions#destroy', :as => 'logout'

  resources :dashboards, :only => [:index, :show], :controller => "organization_dashboards"

  resources :surveys, :only => [:new, :create, :destroy, :index] do
    resources :dashboard, :only => [:index, :show], :controller => 'survey_dashboard'
    resource :publication, :only => [:update, :edit, :destroy] do
      get 'unpublish'
      post 'allocate'
    end
    member do
      get  "report"
    end
    get 'build'
    put 'finalize'
    put 'archive'
    get 'midline'
    get  "public_response" => "responses#create"
    post  "public_response" => "responses#create"
    resources :responses, :only => [:new, :create, :index, :edit, :show, :update, :destroy] do
      collection { get "generate_excel" }
      member do
        put "complete"
      end
    end
  end

=begin
    namespace :v2_survey_builder do
      resources :surveys, :only => [:new, :create, :destroy, :index] do
        member { get 'report' }
        get 'build'
        put 'finalize'
        put 'archive'
        match "public_response" => "responses#create"
      end
    end
=end


  resources :records, :only => [:create, :destroy]

  # root :to => 'organization_dashboards#show', :constraints =>  user_currently_logged_in? 
  # root :to => "organization_dashboards#show", :constraints => SignedInConstraint.new(true)
  # constraints(AuthenticatedUser) do
  #   root :to => "dashboard"
  # end
  #root :to => 'surveys#index'
  root :to => 'corporate_webs#index' 
  # root :to => 'organization_dashboards#show' , :id => 1
end

namespace :api, :defaults => {:format => 'json'} do
  scope :module => :v1 do
    get '/jobs/:id/alive' => "jobs#alive"
    resources :questions, :only => [:create, :update, :show, :destroy] do
      member { post "duplicate" }
    end
    post 'questions/:id/image_upload' => 'questions#image_upload'
    resources :records, :only => [:create, :update] do
      collection { get 'ids_for_response' }
    end
    resources :categories, :only => [:create, :update, :show, :destroy] do
      member { post "duplicate" }
    end
    resources :organizations, :only => :destroy
    resources :audits, :only => [:create, :update]
    resources :options, :only => [:create, :update, :destroy]
    resources :surveys, :only => [:show, :update] do
      get 'questions_count', :on => :collection
      get 'identifier_questions', :on => :member
      post 'duplicate', :on => :member
    end
    get 'deep_surveys', :to => 'deep_surveys#index'
    post '/login' => 'auth#create'
    resources :responses, :only => [:create, :update, :show] do
      member { put "image_upload" }
      collection { get 'count' }
    end
  end
end
end
