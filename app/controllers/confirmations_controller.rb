class ConfirmationsController < ApplicationController
  before_action :fetch_params
  skip_before_action :verify_issue, :verify_user

  def create
    if @user.confirmed_issues.exists? @issue.id
      if secure_togle
        render_from "Issue with auth token #{@issue.issue_auth_token} " \
        "confirmed/unconfirmed by User with auth token #{@user.user_auth_token}"
      else
        render_from(message: 'Confirmation was done less than 24 hours ago', status: :bad_request)
      end
    else
      @issue.users_confirming << @user
      render_from "Issue with auth token #{@issue.issue_auth_token} "\
      "confirmed by User with auth token #{@user.user_auth_token}"
      increase_progresses
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

  def increase_progresses
    @user.increase_achievements_progress 'confirm'
    @user.increase_events_progress 'confirm'
    @issue.user.increase_achievements_progress 'confirm_received'
  end

  def secure_togle
    @confirmation = @user.confirmations.find_by_issue_id @issue.id
    next_day = Time.parse((@confirmation.updated_at + 60).strftime("%Y-%m-%dT%H:%M:%S"))
    return false if Time.now < next_day
    @confirmation.confirmed = !@confirmation.confirmed
    @confirmation.save!
    increase_progresses if @confirmation.confirmed
    return true
  end
end
