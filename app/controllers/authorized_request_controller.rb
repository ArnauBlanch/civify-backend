# Controller to return the current user previous token authorization
class AuthorizedRequestController < ApplicationController
  def me
    render_from current_user
  end
end
