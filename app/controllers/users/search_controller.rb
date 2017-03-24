# Search users by username or email controller
class Users::SearchController < ApplicationController
  def create
    body = JSON.parse(request.raw_post)
    if body['username']
      if User.find_by(username: body['username'])
        render json: { message: 'User exists' }, status: :ok
      else
        render json: { message: 'User not exists' },
               status: :not_found
      end
    elsif body['email']
      if User.find_by(email: body['email'])
        render json: { message: 'User exists' }, status: :ok
      else
        render json: { message: 'User not exists' }, status: :not_found
      end
    else
      render json: { message: 'Username or email must be provided' },
             status: :bad_request
    end
  end
end
