class PasswordResetsController < ApplicationController
  before_action :set_user, only: :update
  before_action :validate_user, only: :update
  before_action :check_expiration, only: :update
  skip_before_action :authenticate_request

  def create
    @user = User.find_by(email: params[:password_reset][:email])
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      render json: { message: 'Email sent' }, status: :ok
    else
      render json: { message: 'User does not exist' }, status: :not_found
    end
  end

  def update
    if @user
      if params[:user][:password].empty?
        render json: { message: 'Password can\'t be blank' }, status: :unprocessable_entity
      elsif @user.update_attributes user_params
        @user.update_attribute(:reset_digest, nil)
        render json: { message: 'Password reseted successfully' }, status: :ok
      else
        render json: { message: 'Invalid passwords' }, status: :unprocessable_entity
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def set_user
    @user = User.find_by(email: params[:email])
    render json: { message: 'User does not exist' }, status: :not_found if @user.nil?
  end

  def validate_user
    unless @user && @user.authenticated?(:reset, params[:id])
      render json: { message: 'Invalid token' }, status: :bad_request
    end
  end

  def check_expiration
    if @user.password_reset_expired?
      render json: { message: 'The password reset token has expired' }, status: :unauthorized
    end
  end
end
