class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request

  def login
    command = AuthenticateUser.call(params[:username], params[:email], params[:password])

    if command.success?
      render json: { auth_token: command.result }
    else
      error_status = Rack::Utils::SYMBOL_TO_STATUS_CODE[:unauthorized] if command.errors[:invalid_credentials]
      error_status ||= Rack::Utils::SYMBOL_TO_STATUS_CODE[:not_found] if command.errors[:not_found]
      error_status ||= Rack::Utils::SYMBOL_TO_STATUS_CODE[:bad_request]
      render json: { error: command.errors }, status: error_status
    end
  end
end