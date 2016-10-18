Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  devise_for :users, :skip => [:registrations]
  as :user do
    get 'users/edit', to: 'devise/registrations#edit',
                      as: 'edit_user_registration'
    put 'users', to: 'devise/registrations#update', as: 'user_registration'
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

  # Heartbeat to get last import DateTime

  # resources :vaccine_doses
  resources :patients, only: [:index, :show]

  # xml importation
  post '/xml', to: 'importer#import_file'
  get '/xml', to: 'importer#index'

  # API for importing Patient Data from the Extractor
  get '/heartbeat', to: 'api#heartbeat'
  post '/patient_data', to: 'api#import_patient_data'
  post '/vaccine_dose_data', to: 'api#import_vaccine_dose_data'

  # You can have the root of your site routed with "root"
  root 'welcome#index'
end
