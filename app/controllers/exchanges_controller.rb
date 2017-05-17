class ExchangesController < ApplicationController

  # GET /users/:user_auth_token/exchanged_awards
  def index
    set_user
    json_response @user.exchanged_awards
  end

  # POST /awards/:award_auth_token/exchange
  def create
    set_user
    set_award_to_exchange
    @user.exchanged_awards << @award
    head :ok
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
