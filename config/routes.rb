Rails.application.routes.draw do
  get 'bug/new'
  get 'bug/comment'
  post 'bug/status'
  post 'bug/status_update', to: 'bug#status_update'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
