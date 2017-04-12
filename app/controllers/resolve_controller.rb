class ResolveController < ApplicationController
  before_action :setup

  # GET /issues/:issue_auth_token/resolve?user=user_auth_token
  def index
    if @issue.resolutions.find_by(user_auth_token: params[:user]).nil?
      render json: { message: 'Resolution does not exist' }, status: :not_found
    else
      render json: { message: 'Resolution exists' }, status: :ok
    end
  end

  # POST /issues/:issue_auth_token/resolve
  def create
    if @user.resolutions.exists?(@issue.id)
      render json: { message: 'Resolution already exists' }, status:
          :bad_request
    elsif @user.resolutions << @issue
      @issue.resolved_votes += 1
      @issue.save
      render json: { message: 'Resolution done' }, status: :ok
    else
      render json: { message: 'Could not do the confirmation' }, status:
          :bad_request
    end
  end

  private

  def setup
    @issue = Issue.find_by(issue_auth_token: params[:issue_auth_token])
    if @issue.nil?
      render json: { message: 'Issue not found' }, status: :not_found
    end
    @user = User.find_by(user_auth_token: params[:user])
    if @user.nil?
      render json: { message: 'User not found' }, status: :not_found
    end
  end
end
