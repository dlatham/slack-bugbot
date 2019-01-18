Rails.application.routes.draw do
  #Bugbot (manuscript / slack) routes
  get 'bug/new'
  get 'bug/comment'
  post 'bug/status'
  post 'bug/status_update', to: 'bug#status_update'
  post 'bug/status_closed', to: 'bug#status_closed'

  #Confluence add on routes
  get '/confluence/descriptor', to: 'confluence#descriptor'
  post 'confluence/installed', to: 'confluence#installed'
  post 'confluence/uninstalled', to: 'confluence#uninstalled'
  get 'confluence/list/:id', to: 'confluence#list'
  get 'confluence/backlog/:id', to: 'confluence#backlog'
  get 'confluence/backlog/vote/:id', to: 'confluence#vote'
  post 'confluence/backlog/create', to: 'confluence#save_backlog_item'
  get 'confluence/new', to: 'confluence#new'
  get 'confluence/poll/:pollname', to: 'confluence#poll'
  post 'confluence/poll/:pollname/create_question', to: 'confluence#create_poll_question'
  post 'confluence/poll/:pollname/vote', to: 'confluence#create_poll_vote'
end
