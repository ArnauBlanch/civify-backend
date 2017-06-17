class ResolveController < ApplicationController
  before_action :setup
  skip_before_action :verify_issue, :verify_user

  RESOLVE_IN = 10

  # POST /issues/:issue_auth_token/resolve
  def create
    if @issue.resolved
      render_from(message: 'Could not do the resolution', status: :bad_request)
    elsif @user.resolved_issues.exists? @issue.id
      if secure_toggle
        if @resolution.marked_resolved
          increase_resolved_votes
        else
          decrease_resolved_votes
        end
      else
        render_from(message: "Confirmation was done less than 24 hours ago : #{@wait_time}", status: :bad_request)
      end
    else
      @issue.users_resolving << @user
      increase_resolved_votes
    end
  end

  private

  def setup
    @issue = Issue.find_by(issue_auth_token: params[:issue_auth_token])
    @user = User.find_by(user_auth_token: params[:user])
    check_user_exists @user
  end

  def increase_progresses
    @user.increase_progress 'resolve'
    @issue.user.increase_progress 'resolve_received'
  end

  def secure_toggle
    @resolution = @user.resolutions.find_by_issue_id @issue.id
    next_time_available = Time.parse((@resolution.updated_at + WAITING_TIME).strftime('%Y-%m-%dT%H:%M:%S'))
    @wait_time = (next_time_available - Time.now).to_i
    return false if Time.now < next_time_available
    @resolution.marked_resolved = !@resolution.marked_resolved
    @resolution.save!
    true
  end

  def increase_resolved_votes
    @issue.resolved_votes += 1
    increase_progresses
    if @issue.resolved_votes >= RESOLVE_IN
      @issue.resolved = true
      @issue.user.increase_progress 'issues_resolved'
    end
    save! @issue
    render_from 'Resolution added'
  end

  def decrease_resolved_votes
    @issue.resolved_votes -= 1
    save! @issue
    render_from 'Resolution deleted'
  end
end
