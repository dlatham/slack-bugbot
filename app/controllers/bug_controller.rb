class BugController < ApplicationController
 
  require 'json'
  skip_before_action :verify_authenticity_token
  before_action :check_token

  def new
  end

  def comment
  end

  def status
  
  end

  def status_update
  	client = Slack::Web::Client.new
  	@title = 'Case ' + params['casenumber'] + ': ' + params['title']
  	@link = ENV['MANUSCRIPT_URL'] + '/f/cases/' + params['casenumber']
  	
  	if params['category'] == '1'
  		@message = [{fallback: params['title'], color: '#BB4430', pretext: 'A new bug was just created...', title: @title, author_name: params['personeditingname'], title_link: @link, text: params['eventtext'].truncate(50), fields: [{title: 'Priority', value: 'High', short: 'false'}]}]
  		client.chat_postMessage(channel: '#p1-bugs', attachments: @message, as_user: true)
  		render status: 200, body: 'Successful p1 chat'
  	elsif params['category'] == '2'
  		@message = [{fallback: params['title'], color: '#ED7D3A', pretext: 'A new bug was just created...', title: @title, author_name: params['personeditingname'], title_link: @link, text: params['eventtext'].truncate(50), fields: [{title: 'Priority', value: 'Medium', short: 'false'}]}]
  		client.chat_postMessage(channel: '#p2-bugs', attachments: @message, as_user: true)
  		render status: 200, body: 'Successful p2 chat'
  	elsif params['category'].to_i >= 3 
  		#@message = [{fallback: params['title'], color: '#36a64f', pretext: 'A new bug was just created...', title: @title, author_name: params['personeditingname'], title_link: @link, text: params['eventtext'].truncate(50), fields: [{title: 'Priority', value: 'Low', short: 'false'}]}]
  		#client.chat_postMessage(channel: '#p3-bugs', attachments: @message, as_user: true)
  		render status: 200, body: 'Bug status change recognized but not sent to chat'
  	else
  		render status: 400, body: 'Incorrectly formatted request'
  	end
  end

  private

  def check_token
  	if params['t'] != ENV['TOKEN']
  		render status: 401, body: 'Unauthorized request'
  	end
  end
end
