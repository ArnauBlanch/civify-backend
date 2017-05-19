class CoinsController < ApplicationController
  before_action :set_user

  # POST /users/:user_auth_token/coins
  def create
    if !@current_user.admin?
      render json: { message: 'Cannot give money to yourself' }, status: :unauthorized
    elsif params[:coins].nil?
      render json: { message: 'Specify the number of coins' }, status: :bad_request
    else
      @user.coins += params[:coins]
      if @user.save
        render json: @user, status: :ok
      else
        render json: { message: @user.errors.full_messages[0] }, status: :bad_request
      end
    end
  end

  private

  def set_user
    @user = User.find_by(user_auth_token: params[:user_auth_token])
  end
end
