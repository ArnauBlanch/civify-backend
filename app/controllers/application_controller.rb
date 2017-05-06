# ApplicationController global controller configurations
class ApplicationController < ActionController::API
  include ExceptionHandler
  include Response
  include RewardsConstants
  # Requires authentication token before requesting resources
  # Moreover checks that update target is the current user
  before_action :authenticate_request

  attr_reader :current_user

  private

  def authenticate_request
    auth_command = AuthorizeApiRequest.call(request.headers)
    if auth_command.success?
      @current_user = auth_command.result
      verify_issue_auth if verify_user_auth?
    else
      render json: { message: auth_command.errors.values[0].first }, status: :unauthorized
    end
  end

  def verify_user_auth?
    user_auth_token = params[:user_auth_token]
    return true unless user_auth_token
    return false unless check_user_exists(User.find_by_user_auth_token(user_auth_token))
    if critical_request? && !current_user?(user_auth_token)
      render json: { message: 'Cannot update other users' }, status: :unauthorized
      return false
    end
    true
  end

  def verify_issue_auth
    issue_auth_token = params[:issue_auth_token]
    return true unless issue_auth_token
    issue = Issue.find_by_issue_auth_token(issue_auth_token)
    return false unless check_issue_exists(issue)
    if critical_request? && !pertains_to_current_user?(issue)
      render json: { message: "Cannot update other's issues" }, status: :unauthorized
    end
  end

  def critical_request?
    !@current_user.admin? && request.request_method != :get.to_s
  end

  def current_user?(user_auth_token)
    user_auth_token == @current_user.user_auth_token
  end

  def pertains_to_current_user?(issue)
    current_user?(issue.user.user_auth_token)
  end

  def check_user_exists(user)
    return true if user
    render json: { message: 'User not found' }, status: :not_found
    false
  end

  def check_issue_exists(issue)
    return true if issue
    render json: { message: 'Issue not found' }, status: :not_found
    false
  end

  def add_reward!(user, coins = 0, xp = 0)
    user.coins += coins
    user.xp += xp
    user.save!
    rewards = {}
    rewards[:coins] = coins if coins > 0
    rewards[:xp] = xp if xp > 0
    rewards
  end
end
