class ResolveController < ApplicationController
  before_action :setup
  skip_before_action :verify_issue, :verify_user

  RESOLVE_IN = 10

  # POST /issues/:issue_auth_token/resolve
  def create
    if @issue.resolutions.exists?(@user)
      @issue.resolutions.delete(@user)
      @issue.resolved_votes -= 1
      @issue.save
      render json: { message: 'Resolution deleted' }, status: :ok
    else
      if @issue.resolutions << @user
        @issue.resolved_votes += 1
        if @issue.resolved_votes >= RESOLVE_IN
          @issue.resolved = true
        end
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
    check_user_exists @user
  end
end
