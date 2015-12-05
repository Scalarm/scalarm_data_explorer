Rails.application.routes.draw do

  root 'status#welcome'

  get 'status' => 'status#status'

  resources :panels, only: [:show]
  resources :moes, only: [:show]
  resources :chart_instances, only: [:show]
  resources :cluster_infos, only: [:show]
  resources :modals, only: [:show]

  match '*path' => 'application#cors_preflight_check', via: :options

  # default readme in this file has been deleted

end
