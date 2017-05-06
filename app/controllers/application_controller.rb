# ApplicationController global controller configurations
class ApplicationController < ActionController::API
  include ExceptionHandler
  include Response
  # Requires authentication token before requesting resources
  # Moreover checks that update target is the current user
  before_action :authenticate_request

  attr_reader :current_user

  private

  def authenticate_request
    auth_command = AuthorizeApiRequest.call(request.headers)
    if auth_command.success?
      @current_user = auth_command.result
      if !@current_user.admin? && request.request_method != :get.to_s
        verify_issue_auth if verify_user_auth?
      end
    else
      render json: { message: auth_command.errors.values[0].first },
             status: :unauthorized
    end
  end

  def verify_user_auth?
    user_auth_token = params[:user_auth_token]
    return true unless user_auth_token
    unless User.find_by_user_auth_token(user_auth_token)
      check_user_exists(nil)
      return false
    end
    unless current_user?(user_auth_token)
      render json: { message: 'Cannot update other users' }, status: :unauthorized
      return false
    end
    true
  end

  def verify_issue_auth
    issue_auth_token = params[:issue_auth_token]
    return true unless issue_auth_token
    issue = Issue.find_by_issue_auth_token(issue_auth_token)
    unless issue
      check_issue_exists(nil)
      return false
    end
    unless pertains_to_current_user?(issue)
      render json: { message: "Cannot update other's issues" }, status: :unauthorized
    end
  end

  def current_user?(user_auth_token)
    user_auth_token == @current_user.user_auth_token
  end

  def pertains_to_current_user?(issue)
    current_user?(issue.user.user_auth_token)
  end

  def check_user_exists(user)
    render json: { message: 'User not found' }, status: :not_found unless user
  end

  def check_issue_exists(issue)
    render json: { message: 'Issue not found' }, status: :not_found unless issue
  end
end
