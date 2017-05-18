# ApplicationController global controller configurations
class ApplicationController < ActionController::API
  include ExceptionHandler
  include Response
  include RewardsConstants
  include AuthorizationController

  # Requires authentication token before requesting resources
  # Skip if route does not require Authorization header
  before_action :authenticate_request

  # Checks that update target is the current user unless is admin
  # Skip if route can perform a non-GET method with user_auth_token different than current user
  before_action :verify_user, :verify_issue, :verify_award

  # Checks that params exists and performs security verifications if needed
  # PLEASE, DO NOT SKIP THIS
  before_action :verify_user_auth, :verify_issue_auth, :verify_award_auth

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
