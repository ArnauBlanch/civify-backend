# Search users by username or email controller
class Users::SearchController < ApplicationController
  skip_before_action :authenticate_request

  def create
    body = JSON.parse(request.raw_post)
    if body['username']
      if User.find_by(username: body['username'])
        user_exists
      else
        user_not_exists
      end
    elsif body['email']
      if User.find_by(email: body['email'])
        user_exists
      else
        user_not_exists
      end
    else
      render json: { message: 'Username or email must be provided' }, status: :bad_request
    end
  end

  def user_exists
    render_from 'User exists'
  end

  def user_not_exists
    render_from(message: 'User not exists', status: :not_found)
  end
end
