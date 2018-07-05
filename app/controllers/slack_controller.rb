class SlackController < ApplicationController

	require 'json'
  	skip_before_action :verify_authenticity_token
  	before_action :check_token

  def listen

  end

end
