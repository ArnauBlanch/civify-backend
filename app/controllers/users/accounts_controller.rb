class Users::AccountsController < ApplicationController
  # POST /users/accounts
  def create
    @user = User.new(user_params)
    if @user.save
      json_response(@user, 201)
    else
      render status: :unprocessable_entity
    end
  end

  # GET /users/accounts
  def index
    params.permit(:find_by, :value)
    if params[:find_by] == 'username'
      @user = User.find_by(username: params[:value])
      if @user
        json_response(@user, :ok)
      else
        render status: :not_found
      end
    elsif params[:find_by] == 'email'
      @user = User.find_by(email: params[:value])
      if @user
        json_response(@user, :ok)
      else
        render status: :not_found
      end
    else
      render status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:username, :email, :first_name, :last_name,
                  :password, :password_confirmation)
  end
end
