Rails.application.routes.draw do

  root 'status#welcome'

  get 'status' => 'status#status'

  resources :panels, only: [:index, :show]
  resources :moes, only: [:show]
  resources :chart_instances, only: [:show]
  resources :cluster_infos, only: [:show]
  resources :modals, only: [:show]
  resources :predictions
  match '*path' => 'application#cors_preflight_check', via: :options

  get 'predictions/evaluate' => 'predictions#evaluate'
  # default readme in this file has been deleted

end
