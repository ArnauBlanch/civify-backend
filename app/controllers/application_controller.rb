# ApplicationController global controller configurations
class ApplicationController < ActionController::API
  # Handles some exceptions with common handling
  include ExceptionHandler
  # Constants utils for using with rewards
  include RewardsConstants
  # Authorization controller with common and security verifications
  include AuthorizationController
  # Utilities to render results, give rewards and manage objects
  include RenderUtils

  # Requires authentication token before requesting resources
  # Skip if route does not require Authorization header
  before_action :authenticate_request

  # Checks that update target is the current user unless is admin
  # Skip if route can perform a non-GET method with user_auth_token different than current user
  before_action :verify_user, :verify_issue, :verify_award

  # Checks that params exists and performs security verifications if needed
  # PLEASE, DO NOT SKIP THIS
  before_action :verify_user_auth, :verify_issue_auth, :verify_award_auth

  def set_current_user(model)
    model.current_user = current_user
  end

end
