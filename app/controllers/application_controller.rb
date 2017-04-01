# ApplicationController global controller configurations
class ApplicationController < ActionController::API
  include ExceptionHandler
  include Response
  # Requires authentication token before requesting resources
  before_action :authenticate_request

  attr_reader :current_user

  private

  def authenticate_request
    auth_command = AuthorizeApiRequest.call(request.headers)
    if auth_command.success?
      @current_user = auth_command.result
    else
      render json: { error: auth_command.errors.values[0].first },
             status: :unauthorized
    end
  end
end
