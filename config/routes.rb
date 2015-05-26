Rails.application.routes.draw do

  root 'status#welcome'

  get 'status' => 'status#status'

  resources :script_tags, only: [:show]
  resources :panels, only: [:index, :show]
  resources :scripts, only: [:show]
  resources :moes, only: [:show]

  # default readme in this file has been deleted

end
