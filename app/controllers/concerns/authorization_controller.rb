module AuthorizationController

  attr_reader :current_user

  def authenticate_request
    auth_command = AuthorizeApiRequest.call(request.headers)
    if auth_command.success?
      @current_user = auth_command.result
    else
      render json: { message: auth_command.errors.values[0].first }, status: :unauthorized
    end
  end

  def needs_admin(message = 'You are not allowed to perform this action.')
    return unless @current_user
    unauthorize(message, !@current_user.admin?)
  end

  def needs_admin_or_business(message = 'You are not allowed to perform this action.')
    return unless @current_user
    unauthorize(message, !@current_user.admin? && !@current_user.business?)
  end

  def unauthorize(message, condition = true)
    render json: { message: message }, status: :unauthorized if condition
  end

  def verify_user_auth
    user_auth_token = params[:user_auth_token]
    return unless user_auth_token
    return unless check_user_exists(User.find_by_user_auth_token(user_auth_token))
    return unless @current_user
    unauthorize('Cannot update other users',
                @verify_user && critical_request? && !current_user?(user_auth_token))
  end

  def verify_issue_auth
    issue_auth_token = params[:issue_auth_token]
    return unless issue_auth_token
    issue = if params[:user_auth_token] # and it's verified that exists (checked by before_action left-to-right order)
              User.find_by_user_auth_token!(params[:user_auth_token]).issues.find_by_issue_auth_token(issue_auth_token)
            else
              Issue.find_by_issue_auth_token(issue_auth_token)
            end
    return unless check_issue_exists(issue)
    return unless @current_user
    unauthorize("Cannot update other's issues",
                @verify_issue && critical_request? && !current_user?(issue.user.user_auth_token))
  end

  def verify_award_auth
    award_auth_token = params[:award_auth_token]
    return unless award_auth_token
    award = Award.find_by_award_auth_token(award_auth_token)
    return unless check_award_exists(award)
    return unless @current_user
    unauthorize("Cannot update other's awards",
                @verify_award && critical_request? && !current_user?(award.commerce_offering.user_auth_token))
  end

  def critical_request?
    !@current_user.admin? && request.request_method != 'GET'
  end

  def current_user?(user_auth_token)
    user_auth_token == @current_user.user_auth_token
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

  def check_award_exists(award)
    return true if award
    render json: { message: 'Award not found' }, status: :not_found
    false
  end

  def verify_user
    @verify_user = true
  end

  def verify_issue
    @verify_issue = true
  end

  def verify_award
    @verify_award = true
  end
end