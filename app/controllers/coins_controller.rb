class CoinsController < ApplicationController
  before_action -> { needs_admin('Cannot give money to yourself') }
  before_action :set_user

  # POST /users/:user_auth_token/coins
  def create
    if params[:coins].nil?
      render_from(message: 'Specify the number of coins', status: :bad_request)
    else
      save_render!(@user, coins: params[:coins], status: :ok, add_rewards: true)
    end
  end

  private

  def set_user
    @user = User.find_by(user_auth_token: params[:user_auth_token])
  end
end
