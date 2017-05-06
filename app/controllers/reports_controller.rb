# Reports controller class
class ReportsController < ApplicationController
  before_action :fetch_params

  def create
    if @user.reported_issues.exists? @issue.id
      @issue.users_reporting.destroy @user
      render json: { message: "Issue with auth token #{@issue.issue_auth_token} "\
      "unreported by User with auth token #{@user.user_auth_token}" }
    else
      @issue.users_reporting << @user
      render json: { message: "Issue with auth token #{@issue.issue_auth_token} "\
      "reported by User with auth token #{@user.user_auth_token}" }
    end
  end

  private

  def fetch_params
    @issue = Issue.find_by!(issue_auth_token: params[:issue_auth_token])
    @user = if params[:user_auth_token]
              User.find_by!(user_auth_token: params[:user_auth_token])
            else
              current_user
            end
  end
end
