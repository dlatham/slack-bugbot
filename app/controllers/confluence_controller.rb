class ConfluenceController < ApplicationController
	require 'trello'
	require 'dotenv'

	Trello.configure do |config|
		config.developer_public_key = ENV['TRELLO_KEY']
		config.member_token = ENV['TRELLO_TOKEN']
	end

	include AtlassianJwtAuthentication
	
	skip_before_action :verify_authenticity_token
	before_action only: [:installed] do
		on_add_on_installed
	end
	before_action :on_add_on_uninstalled, only: [:uninstalled]
	before_action only: [:get_task] do |controller|
		controller.send(:verify_jwt, 'connect-add-on-roadster-roadmap')
	end

	def descriptor
	end

	def installed
		#render :nothing => true
	end

	def uninstalled
		#render :nothing => true, status: 200
	end

	def list
		@card = Hash.new()
  		@list = Trello::Board.find(params[:id]).lists
  		@list.each do |item|
  			@card[item.id] = Trello::List.find(item.id).cards
  		end
  		response.headers["X-FRAME-OPTIONS"] = "ALLOW-FROM #{ENV['CONFLUENCE_URL']}"
	end

end