# Controller to return the current user previous token authorization
class AuthorizedRequestController < ApplicationController
  def me
    render json: current_user, except: [:id, :password_digest]
  end
end
