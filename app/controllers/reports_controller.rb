# Reports controller class
class ReportsController < ApplicationController
  before_action :fetch_params
  skip_before_action :verify_issue, :verify_user

  DELETE_IN = 10

  def create
    if @user.reported_issues.exists? @issue.id
      if secure_togle
        render_from "Issue with auth token #{@issue.issue_auth_token} " \
        "reported/unreported by User with auth token #{@user.user_auth_token}"
      else
        render_from(message: "Report was done less than 24 hours ago : #{@wait_time}", status: :bad_request)
      end
    else
      @issue.users_reporting << @user
      render_from "Issue with auth token #{@issue.issue_auth_token} "\
      "reported/unreported by User with auth token #{@user.user_auth_token}"
      check_reports
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

  def secure_togle
    @report = @user.reports.find_by_issue_id @issue.id
    next_day = Time.parse((@report.updated_at + WAITING_TIME).strftime("%Y-%m-%dT%H:%M:%S"))
    @wait_time = (next_day - Time.now).to_i
    return false if Time.now < next_day
    @report.marked_reported = !@report.marked_reported
    @report.save!
    check_reports if @report.marked_reported
    return true
  end

  def check_reports
    if @issue.reports.size >= DELETE_IN
      destroy! @issue
    end
  end
end
