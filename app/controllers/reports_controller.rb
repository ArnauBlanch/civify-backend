# Reports controller class
class ReportsController < ApplicationController
  before_action :fetch_params
  skip_before_action :verify_issue, :verify_user

  DELETE_IN = 10

  def create
    if @user.reported_issues.exists? @issue.id
      @issue.users_reporting.destroy @user
      render_from(message: "Issue with auth token #{@issue.issue_auth_token} "\
      "unreported by User with auth token #{@user.user_auth_token}")
    else
      @issue.users_reporting << @user
      render_from(message: "Issue with auth token #{@issue.issue_auth_token} "\
      "reported by User with auth token #{@user.user_auth_token}")
      if @issue.reports.size >= DELETE_IN
        destroy! @issue
      end
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
