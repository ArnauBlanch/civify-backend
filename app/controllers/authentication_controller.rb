# Authentication Controller (login controller)
class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request

  def login
    auth_command = AuthenticateUser.call(
      params[:password],
      params[:username],
      params[:email]
    )

    if auth_command.success?
      render_from(auth_token: auth_command.result)
    else
      render_login_error auth_command.errors
    end
  end

  def render_login_error(errors)
    error_status = if errors[:invalid_credentials]
                     :unauthorized
                   elsif errors[:not_found]
                     :not_found
                   else
                     :bad_request
                   end
    render_from(message: errors.values[0].first, status: error_status)
  end
end
