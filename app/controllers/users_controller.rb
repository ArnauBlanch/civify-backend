# Users controller
class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]

  # GET /users
  def index
    @users = User.all
    render json: @users.to_json(except: :id), status: :ok
  end

  # GET /users/[:user_auth_token]
  def show
    render json: @user.to_json(except: :id), status: :ok
  end

  # POST /users
  def create
    @user = User.new(user_params)
    if @user.save
      render json: @user.to_json(except: :id), status: :created
    else
      render json: { message: 'User not created' }, status: :bad_request
    end
  end

  # DELETE /users/[:user_auth_token]
  def destroy
    if @user.destroy
      render json: { message: 'User deleted' }, status: :ok
    else
      render json: { message: 'User not deleted' }, status: :bad_request
    end
  end

  private

  def user_params
    params.permit(:username, :email, :first_name, :last_name,
                  :password, :password_confirmation)
  end

  def set_user
    @user = User.find_by(user_auth_token: params[:user_auth_token])
    render json: { message: 'User not found' }, status: :not_found if @user.nil?
  end
end
