class CoinsController < ApplicationController
  before_action :set_user

  # POST /users/:user_auth_token/coins
  def create
    if params[:coins].nil?
      render json: { message: 'Specify the number of coins' }, status:
          :bad_request
    else
      @user.coins += params[:coins]
      @user.save(validate: false)
      render json: @user, status: :ok
    end
  end

  private

  def set_user
    @user = User.find_by(user_auth_token: params[:user_auth_token])
    render json: { message: 'User not found' }, status: :not_found if @user.nil?
  end
end
