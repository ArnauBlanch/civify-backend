class BadgesController < ApplicationController
  include Xattachable

  # GET /user/:user_auth_token/badges
  def index
    set_user
    Badge.current_user = @user
    render_from @user.badges
  end

  private

  def set_user
    @user = if params[:user_auth_token]
              User.find_by!(user_auth_token: params[:user_auth_token])
            else
              current_user
            end
  end
end