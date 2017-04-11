class ConfirmationsController < ApplicationController
  before_action :fetch_params

  def create
    if @user.confirmed_issues.exists? @issue.id
      @issue.users_confirming.destroy @user
      render json: { message: 'Issue with auth token'\
      " #{@issue.issue_auth_token} "\
      "unconfirmed by User with auth token #{@user.user_auth_token}" }
    else
      @issue.users_confirming << @user
      render json: { message: 'Issue with auth token'\
      " #{@issue.issue_auth_token} "\
      "confirmed by User with auth token #{@user.user_auth_token}" }
    end
  end

  private

  def fetch_params
    @issue = Issue.find_by!(issue_auth_token: params[:issue_auth_token])
    @user = if params[:user_auth_token]
              @user = User.find_by!(user_auth_token: params[:user_auth_token])
            else
              @user = current_user
            end
  end
end
