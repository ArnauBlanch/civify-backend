class UsesController < ApplicationController
  # POST /use
  def create
    set_user
    return unless set_exchange
    if !@exchange.used
      @exchange.used = true
      @exchange.save!
      head :ok
    else
      render json: { message: 'User has already used this buyed award' }, status: :bad_request if @exchange.used
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

  def set_exchange
    @exchange = Exchange.find_by(exchange_auth_token: params[:exchange_auth_token])
    return true if @exchange
    render json: { message: 'Exchange not found' }, status: :not_found
    false
  end

end
