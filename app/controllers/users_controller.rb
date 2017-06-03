# Users controller
class UsersController < ApplicationController
  before_action :set_user, only: [:show, :destroy]
  skip_before_action :authenticate_request, only: [:create]

  # GET /users
  def index
    @users = User.all
    render_from @users.to_json(except: json_exclude)
  end

  # GET /users/[:user_auth_token]
  def show
    render_from @user.to_json(except: json_exclude)
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
      create_achievement_progresses(@user) unless @user.kind == :business.to_s
    end
  end

  def create_user(params)
    @user = User.new(params)
    save_render! @user
  end

  # DELETE /users/[:user_auth_token]
  def destroy
    destroy! @user
    render_from 'User deleted'
  end

  private

  def user_params
    params.permit(:username, :email, :first_name, :last_name,
                  :password, :password_confirmation, :kind)
  end

  def set_user
    @user = User.find_by(user_auth_token: params[:user_auth_token])
  end

  def json_exclude
    [:id, :password_digest, :email, :created_at, :updated_at, :xp]
  end

  def create_achievement_progresses(user)
    Achievement.all.each do |a|
      a.users << user
    end
  end
end
