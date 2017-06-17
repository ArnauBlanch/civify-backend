class UsesController < ApplicationController
  # POST /use
  def create
    set_user
    return unless set_exchange
    if !@exchange.used
      @exchange.used = true
      @exchange.save!
      render_from 'Exchange used'
      @user.increase_progress 'use'
    else
      render_from(message: 'User has already used this award', status: :unauthorized) if @exchange.used
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

  def get_commerce
    @award = Award.find_by_id! @exchange.award_id
    @commerce = @award.commerce_offering
  end

  def set_exchange
    @exchange = Exchange.find_by(exchange_auth_token: params[:exchange_auth_token])
    get_commerce if @exchange
    return true if @exchange and current_user.id == @commerce.id
    if !@exchange
      render_from(message: 'Exchange not found', status: :not_found)
    else
      render_from(message: "This award doesn't belong to this commerce", status: :unauthorized)
    end
    false
  end
end
