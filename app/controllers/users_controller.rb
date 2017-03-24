# Users controller
class UsersController < ApplicationController
  # POST /users
  def create
    body = JSON.parse(request.raw_post)
    @user = User.new(body['user'])
    if @user.save
      render json: { message: 'User created' }, status: :created
    else
      render json: { message: 'User not created' }, status: :bad_request
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :first_name, :last_name,
                                 :password, :password_confirmation)
  end
end
