class ExchangesController < ApplicationController
  skip_before_action :verify_award, only: :create

  # GET /users/:user_auth_token/exchanged_awards
  def index
    set_user
    render_from @user.exchanges
  end

  # POST /awards/:award_auth_token/exchange
  def create
    set_user
    set_award_to_exchange
    if @user.coins < @award.price
      render_from(message: "You do not have enough coins (needed $#{@award.price} but have $#{@user.coins})",
                  status: :unauthorized)
    else
      @user.exchanged_awards << @award
      render_from(user: @user, coins: -@award.price, xp: XP.exchange_reward(@award.price), add_rewards: true)
      @user.increase_achievements_progress 'reward'
    end
  rescue ActiveRecord::RecordInvalid => e
    @user.exchanged_awards.delete!(@award)
    raise e
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
