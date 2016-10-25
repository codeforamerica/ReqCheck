Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  devise_for :users, skip: [:registrations, :sessions]
  as :user do
    # Allow edits to a user profile
    get 'users/edit', to: 'devise/registrations#edit',
                      as: 'edit_user_registration'
    put 'users', to: 'devise/registrations#update',
                 as: 'user_registration'

    # Sign in and out routes
    post 'users/sign_in', to: 'devise/sessions#create',
                          as: :user_session
    get 'users/sign_out', to: 'devise/sessions#destroy',
                          as: :destroy_user_session
  end

  get 'welcome/index'

  # To have a /login endpoint
  devise_scope :user do
    get 'login', to: 'devise/sessions#new'
  end

  # authenticated :user do
  #   root to: 'admin/dashboard#index', as: :authenticated_root
  # end
  # unauthenticated :user do
  #   root to: 'users/sessions#new', as: :unauthenticated_root
  # end

  resources :patients, only: [:index, :show]
  # resources :vaccine_doses, only: [:show]

  # xml importation
  post '/xml', to: 'xml_importer#import_file'
  get '/xml', to: 'xml_importer#index'

  # API for importing Patient Data from the Extractor
  post '/heartbeat', to: 'api#heartbeat'
  post '/patient_data', to: 'api#import_patient_data'
  post '/vaccine_dose_data', to: 'api#import_vaccine_dose_data'

  # You can have the root of your site routed with "root"
  root 'welcome#index'
end
