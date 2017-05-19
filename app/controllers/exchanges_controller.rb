class ExchangesController < ApplicationController
  skip_before_action :verify_award, only: :create

  # GET /users/:user_auth_token/exchanged_awards
  def index
    set_user
    json_response @user.exchanges
  end

  # POST /awards/:award_auth_token/exchange
  def create
    set_user
    set_award_to_exchange
    if @user.coins < @award.price
      render json: { message: "You do not have enough coins (needed $#{@award.price} but have $#{@user.coins})" },
             status: :unauthorized
    else
      rewards = add_reward! @user, -@award.price, XP.exchange_reward(@award.price)
      @user.exchanged_awards << @award
      render json: { rewards: rewards }, status: :ok
    end
  end

  private

  def set_user
    @user = if params[:user_auth_token]
              User.find_by!(user_auth_token: params[:user_auth_token])
            else
              current_user
            end
  end

  def set_award_to_exchange
    @award = Award.find_by!(award_auth_token: params[:award_auth_token])
  end

end
