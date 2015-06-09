Rails.application.routes.draw do

  root 'status#welcome'

  get 'status' => 'status#status'

  resources :script_tags, only: [:show]
  resources :panels, only: [:index, :show]
  resources :scripts, only: [:show]
  resources :moes, only: [:show]
  resources :chart_instances, only: [:show]

  match '*path' => 'application#cors_preflight_check', via: :options

  # default readme in this file has been deleted

end
