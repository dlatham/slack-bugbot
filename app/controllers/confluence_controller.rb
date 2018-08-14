class ConfluenceController < ApplicationController
	require 'trello'
	require 'net/http'
	require 'json'

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
		@attachments = Hash.new()
  		@list = Trello::Board.find(params[:id]).lists
  		@list.each do |list|
  			@card[list.id] = Trello::List.find(list.id, params = {'attachments' => true}).cards
  			@card[list.id].each do |card|
  				card.attachments.each do |attachment|
  					
  					if attachment.url.include? ENV['CONFLUENCE_URL']
  						@attachments[card.id] = attachment.url
  					end
  				end
  			end
  		end
  		response.headers["X-FRAME-OPTIONS"] = "ALLOW-FROM #{ENV['CONFLUENCE_URL']}"
	end

	def backlog
		#custom fields not supported with the trello gem so I needed to parse the JSON myself
		http = Net::HTTP.new("api.trello.com", 443)
		http.use_ssl = true
		req = Net::HTTP::Get.new("/1/lists/#{params[:id]}/cards?key=#{ENV['TRELLO_KEY']}&token=#{ENV['TRELLO_TOKEN']}&customFieldItems=true&fields=name,desc,dateLastActivity,url")
		res = http.request(req)
		@list = JSON.parse(res.body)
		response.headers["X-FRAME-OPTIONS"] = "ALLOW-FROM #{ENV['CONFLUENCE_URL']}"
	end

	def vote
		count = params[:count].to_i + 1
		http = Net::HTTP.new("api.trello.com", 443)
		http.use_ssl = true
		req = Net::HTTP::Put.new("/1/card/#{params[:id]}/customField/#{params[:customfieldid]}/item", initheader = { 'Content-Type' => 'application/json'})
		req.body = {"id" => params[:id], "value" => {"number" => count.to_s}, "key" => ENV['TRELLO_KEY'], "token" => ENV['TRELLO_TOKEN']}.to_json
		#puts req.body
		res = http.request(req)
		@result = JSON.parse(res.body)
		puts @result
		redirect_back fallback_location: { action: "backlog", id: params[:listID] }
	end


end