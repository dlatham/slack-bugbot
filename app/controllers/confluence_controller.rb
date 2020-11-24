class ConfluenceController < ApplicationController
	require 'trello'
	require 'net/http'
	require 'json'
	require 'uri'
	require 'passphrase'

	Trello.configure do |config|
		config.developer_public_key = ENV['TRELLO_KEY']
		config.member_token = ENV['TRELLO_TOKEN']
	end

	include AtlassianJwtAuthentication
	AtlassianJwtAuthentication.context_path = '/confluence'
	
	skip_before_action :verify_authenticity_token
	before_action :on_add_on_installed, only: [:installed]
	before_action :on_add_on_uninstalled, only: [:uninstalled]

	# will respond with head(:unauthorized) if verification fails
	before_action only: [:encrypted_file] do |controller|
		AtlassianJwtAuthentication.context_path = '/confluence'
		controller.send(:verify_jwt, 'connect-add-on-roadster-roadmap')
	end

	before_action only: [:encrypted_file_upload] do |controller|
		if !jwt_check_without_qsh
			render status: 401 and return
		end
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

	def poll
		#Handle a request for a poll name that may or may not exist
		@poll = Poll.find_by(pollname: params[:pollname])
		if !@poll then
			@poll = Poll.new(pollname: params[:pollname], active: params[:active], open_submit: params[:open_submit], expires: params[:expires])
			if @poll.save then
				flash[:success] =  "A new poll has been created."
			else
				flash[:error] = "There was an error creating your poll. Please try again."
			end
		else
			if @poll.questions != nil
				@questions = []
				@poll.questions.each.with_index do |question, i|
					@questions.push({text: question, votes: Pollvote.where(poll_id: @poll.id, question_id: i).count})
				end
				@total_votes = Pollvote.where(poll_id: @poll.id).count
			end
		end
		response.headers["X-FRAME-OPTIONS"] = "ALLOW-FROM #{ENV['CONFLUENCE_URL']}"
	end

	def create_poll_question
		@poll = Poll.find_by(pollname: params[:pollname])
		if @poll.questions == nil
			@poll.questions = [params[:question]]
		else
			@poll.questions.push(params[:question])
		end
		if @poll.save
			flash[:success] = "You've added a suggested topic to this poll."
		else
			flash[:error] = "There was an error saving your topic. Please try again."
		end
		redirect_to controller: "confluence", action: "poll", pollname: @poll.pollname
	end

	def create_poll_vote
		@pollvote = Pollvote.new(poll_id: params[:poll_id], username: params[:username], question_id: params[:question_id])
		if @pollvote.save
			flash[:success] = "Your vote is counted!"
		else
			flash[:error] = "There was an error saving your vote. Please try again."
		end
		redirect_to controller: "confluence", action: "poll", pollname: params[:pollname]
	end

	def new
		#handle a GET request for the new backlog item input form
		response.headers["X-FRAME-OPTIONS"] = "ALLOW-FROM #{ENV['CONFLUENCE_URL']}"
	end


  	def save_backlog_item
  		# Add a new item to the backlog
  		#params.permit(:name, :desc, :email, :dealerships_request, :idList)
  		flash.discard
  		@desc = params[:desc] + "\r\n\r\nRequested by: " + params[:email] + " for the following dealerships: " + params[:dealerships_request]
  		# need to add the idMembers parameter as well
  		@backlog = {name: params[:name], desc: @desc, pos: "bottom", idList: params[:idList]}
  		http = Net::HTTP.new("api.trello.com", 443)
		http.use_ssl = true
		q = "/1/cards?key=#{ENV['TRELLO_KEY']}&token=#{ENV['TRELLO_TOKEN']}&" + @backlog.to_query
		puts q
		req = Net::HTTP::Post.new(q)
		req.set_form_data(@backlog)
		res = http.request(req)
		puts res.code
		puts res.message
		if res.code == '200'
			flash[:success] = "Your request has been added to the backlog and someone will be in touch soon!"
		else
			flash[:error] = "Oh no. Something went wrong. Please try your request again or contact Dave / Jay."
		end
		response.headers.delete "X-Frame-Options"
		response.headers["X-FRAME-OPTIONS"] = "ALLOW-FROM #{ENV['CONFLUENCE_URL']}"
		render 'confluence/new'
  	end

  	def insecure_referral
  		response.headers["X-FRAME-OPTIONS"] = "ALLOW-FROM #{ENV['CONFLUENCE_URL']}"
  	end

  	def render_insecure_referral
  		mem = (params[:fname]!="" ? "fname=" + params[:fname] + "&" : "") + (params[:lname]!="" ? "lname=" + params[:lname] + "&" : "") + (params[:phone]!="" ? "phone=" + params[:phone] + "&" : "") + (params[:custid]!="" ? "custid=" + params[:custid] + "&" : "") + "email=" + params[:email]
  		@url = params[:base_url] + "/express/" + (params[:new_used]=='used' ? "used/" : "") + params[:vin] + "?mem=" + URI.escape(mem, "=&@")
  		# build the URL for CRM email templates
  		case params[:crm]
  		when "elead"
  			@crm_url = params[:base_url] + "/express/" + (params[:new_used]=='used' ? "used/" : "") + "<{SoughtVin}>?mem=fname%3D<{CustFirstName}>%26lname%3D<{CustLastName}>%26phone%3D<{CustHomePhone}>%26email%3D<{CustEMailAddress}>"
  		when "vinsolutions"
  			@crm_url = params[:base_url] + "/express/" + (params[:new_used]=='used' ? "used/" : "") + "[VEHICLE VIN]?mem=fname%3D[CUSTOMER FIRST NAME]%26lname%3D[CUSTOMER LAST NAME]%26phone%3D[CUSTOMER DAY PHONE]%26email%3D[CUSTOMER EMAIL]"
  		end
  		response.headers.delete "X-Frame-Options"
  		response.headers["X-FRAME-OPTIONS"] = "ALLOW-FROM #{ENV['CONFLUENCE_URL']}"
  	end

  	def encrypted_file
  		@jwt = params[:jwt]
  		response.headers["X-FRAME-OPTIONS"] = "ALLOW-FROM #{ENV['CONFLUENCE_URL']}"
  	end

  	def encrypted_file_upload
  		if !params[:upload][:file] || params[:upload][:file] == ""
  			flash[:error] = "No file selected"
  			redirect_to action: 'encrypted_file' and return
  		end

  		file = params[:upload][:file]

  		if file.content_type != "application/octet-stream"
  			flash[:error] = "File should be a GPG-encrypted file"
  			redirect_to action: 'encrypted_file' and return
  		end

  		data = RoadsterGPG.new(encrypted_file: file)

  		response.headers["X-FRAME-OPTIONS"] = "ALLOW-FROM #{ENV['CONFLUENCE_URL']}"
  		send_data data.decrypt, filename: "#{file.original_filename.split(".").first}.txt", type: "text/plain", disposition: 'attachment'

  		#render inline: data.decrypt

  	end


	private

	def poll_vote_params
    	params.require(:poll_id).permit(:username, :question_id)
    	# params.require(:heartbeat).permit(:probe_id, :voltage, :temp, :humid)
  	end

    def jwt_check_without_qsh
    	decoded = JWT.decode(params[:jwt], nil, false, { verify_expiration: AtlassianJwtAuthentication.verify_jwt_expiration, algorithm: 'HS256' })
    	data = decoded[0]
    	jwt_auth = JwtToken.where(client_key: data['iss'], addon_key: 'connect-add-on-roadster-roadmap').first
    	if !jwt_auth
    		return false
    	else
    		return true
    	end
    end


end