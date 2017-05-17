class UsesController < ApplicationController
  # POST /awards/:award_auth_token/exchange
  def create
    set_user
    return unless set_award_to_use
    exchange = @user.exchanges.find_by(award_id: @award.id)
    if !exchange.used
      exchange.used = true
      exchange.save!
      head :ok
    else
      render json: { message: 'User has already used this award' }, status: :bad_request if exchange.used
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

  def set_award_to_use
    @award = Award.find_by!(award_auth_token: params[:award_auth_token])
    return true if @user.exchanged_awards.exists? @award.id
    render json: { message: "User doesn't own this award" }, status: :not_found
    false
  end

end
