class ReferralsController < ApplicationController
	require 'openssl'
	require 'base64'

	def index
		cipher = OpenSSL::Cipher::AES256.new(:CBC)
		cipher.encrypt
		@key = Base64.encode64(cipher.random_key)
	end
end
