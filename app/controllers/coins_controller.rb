class CoinsController < ApplicationController
  before_action -> { needs_admin('Cannot give money to yourself') }
  before_action :set_user

  # POST /users/:user_auth_token/coins
  def create
    if params[:coins].nil?
      render json: { message: 'Specify the number of coins' }, status: :bad_request
    else
      @user.coins += params[:coins]
      save_render(@user)
    end
  end

  private

  def set_user
    @user = User.find_by(user_auth_token: params[:user_auth_token])
  end
end
