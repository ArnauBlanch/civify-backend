class ApplicationController < ActionController::API
  before_action :authenticate_request

  attr_reader :current_user

  private

  def authenticate_request
    authorize_command = AuthorizeApiRequest.call(request.headers)
    @current_user = authorize_command.result if authorize_command.success?
    render json: { error: command.errors }, status: :unauthorized unless @current_user
  end
end
