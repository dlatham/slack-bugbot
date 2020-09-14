class ChatsController < ApplicationController

	skip_before_action :verify_authenticity_token, only: [:create]
	before_action :validate_request

	def create
		begin
			chat = Chat.create(chat_params)
			render json: {message: "ok", id: chat.id}, status: 200
		rescue => e
			Rails.logger.warn e
			render json: {message: "warn"}, status: 200
		end
	end

	def unauthorized
		render json: {message: "unauthorized"}, status: 401 and return
	end

	private

	def validate_request
		unauthorized if params[:token] != ENV['CHAT_TOKEN']
	end

	def chat_params
		params.permit(:dpid, :session, :provider, :data)
	end



end
