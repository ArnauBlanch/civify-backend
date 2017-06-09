# Users controller
class UsersController < ApplicationController
  before_action :set_user, only: [:show, :destroy]
  skip_before_action :authenticate_request, only: [:create]

  # GET /users
  def index
    @users = User.all
    render_from @users
  end

  # GET /users/[:user_auth_token]
  def show
    render_from @user
  end

  # POST /users
  def create
    request_params = user_params
    if request_params[:last_name].blank? && request_params[:kind] == :business.to_s
      request_params[:last_name] = 'business'
    end
    if request_params[:kind] == :admin.to_s
      render_from(message: 'Admin users cannot be created this way for security reasons', status: :unauthorized)
    else
      create_user request_params
    end
  end

  def create_user(params)
    @user = User.new(params)
    save_render! @user, message: 'User created'
    create_achievement_progresses
    create_event_progress
  end

  # DELETE /users/:user_auth_token
  def destroy
    if @user.issues.empty?
      destroy_render!(@user, message: 'User deleted', username: @user.username, user_auth_token: @user.user_auth_token)
    else
      render_from message: 'Cannot delete a user with created issues',
                  username: @user.username, user_auth_token: @user.user_auth_token, status: :bad_request
    end
  end

  private

  def user_params
    params.permit(:username, :email, :first_name, :last_name, :password, :password_confirmation, :kind,
                  :profile_icon)
  end

  def set_user
    @user = User.find_by(user_auth_token: params[:user_auth_token])
  end

  def create_achievement_progresses
    @user.achievements_in_progress << Achievement.all
  end

  def create_event_progress
    @user.events_in_progress << Event.all
  end
end
