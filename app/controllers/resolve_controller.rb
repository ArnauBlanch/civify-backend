class ResolveController < ApplicationController
  before_action :setup

  # POST /issues/:issue_auth_token/resolve
  def create
    if @issue.resolutions.exists?(@user.id)
      @issue.resolutions.delete(@user)
      @issue.resolved_votes -= 1
      @issue.save
      render json: { message: 'Resolution deleted' }, status: :ok
    else
      if @issue.resolutions << @user
        @issue.resolved_votes += 1
        @issue.save
        render json: { message: 'Resolution added' }, status: :ok
      else
        render json: { message: 'Could not do the resolution' }, status:
            :bad_request
      end
    end
  end

  private

  def setup
    @issue = Issue.find_by(issue_auth_token: params[:issue_auth_token])
    @user = User.find_by(user_auth_token: params[:user])
    if @issue.nil?
      render json: { message: 'Issue not found' }, status: :not_found
    elsif @user.nil?
      render json: { message: 'User not found' }, status: :not_found
    end
  end
end
