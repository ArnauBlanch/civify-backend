# Controller for users
class UsersController < ApplicationController
  # POST /users
  def create
    @user = User.new(user_params)
    if @user.save
      json_response(@user, 201)
    else
      render status: 422
    end
  end

  def user_params
    params.permit(:username, :email, :first_name, :last_name,
                  :password, :password_confirmation)
  end
end
