# Users controller
class UsersController < ApplicationController
  before_action :set_user, only: [:show, :destroy]
  skip_before_action :authenticate_request, only: [:create]

  # GET /users
  def index
    @users = User.all
    render json: @users.to_json(except: json_exclude), status: :ok
  end

  # GET /users/[:user_auth_token]
  def show
    render json: @user.to_json(except: json_exclude), status: :ok
  end

  # POST /users
  def create
    request_params = user_params
    if request_params[:last_name].blank? && request_params[:kind] == :business.to_s
      request_params[:last_name] = 'business'
    end
    if request_params[:kind] == :admin.to_s
      render json: { message: 'Admin users cannot be created this way for security reasons' }, status: :unauthorized
    else
      create_user request_params
    end
  end

  def create_user(params)
    @user = User.new(params)
    if @user.save
      render json: { message: 'User created' }, status: :created
    else
      render json: { message: 'User not created' }, status: :bad_request
    end
  rescue ActiveRecord::RecordNotUnique
    render json: { message: 'Already exists' }, status: :bad_request
  rescue
    render json: @user.errors, status: :bad_request
  end

  # DELETE /users/[:user_auth_token]
  def destroy
    if @user.destroy
      render json: { message: 'User deleted' }, status: :ok
    else
      render json: @user.errors, status: :bad_request
    end
  end

  private

  def user_params
    params.permit(:username, :email, :first_name, :last_name,
                  :password, :password_confirmation, :kind)
  end

  def set_user
    @user = User.find_by(user_auth_token: params[:user_auth_token])
    render json: { message: 'User not found' }, status: :not_found if @user.nil?
  end

  def json_exclude
    [:id, :password_digest, :email, :created_at, :updated_at]
  end
end
