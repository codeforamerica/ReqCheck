Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  devise_for :users
  get 'welcome/index'

  # resources :vaccine_doses
  resources :patients, only: [:index, :show]

  # xml importation
  post '/xml', to: 'importer#import_file'
  get '/xml', to: 'importer#index'

  # API for importing Patient Data from the Extractor
  post '/patient_data', to: 'importer#import_patient_data'
  post '/vaccine_dose_data', to: 'importer#import_vaccine_dose_data'

  # You can have the root of your site routed with "root"
  root 'welcome#index'
end
