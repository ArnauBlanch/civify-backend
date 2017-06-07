# Issue controller class
class IssuesController < ApplicationController
  include Xattachable
  before_action :fetch_picture, only: [:create, :update, :update_issue]
  skip_before_action :authenticate_request, only: [:index_issues, :show_issue]
  before_action :set_current_user, only: [:show_issue]

  def index
    set_user
    render_from filter_issues(@user.issues)
  end

  def show
    set_user
    set_user_issue
    @issue.current_user = current_user
    render_from @issue
  end

  def create
    set_user
    @issue = @user.issues.build(issue_params)
    @issue.picture = @picture
    @issue.current_user = current_user
    result = save_render!(@issue, user: @user, coins: COINS::ISSUE_CREATION, xp: XP::ISSUE_CREATION)
    increase_progresses if result
  end

  def update
    set_user
    set_user_issue
    @issue.picture = @picture if @picture
    @issue.current_user = current_user
    update_render!(@issue, issue_params)
  end

  def destroy
    set_user
    set_user_issue
    destroy_render! @issue
  end

  def index_issues
    render_from filter_issues(Issue.all)
  end

  def show_issue
    set_issue
    @issue.current_user = current_user
    render_from @issue
  end

  def update_issue
    set_issue
    @issue.picture = @picture if @picture
    @issue.current_user = current_user
    update_render!(@issue, issue_params)
  end

  def destroy_issue
    set_issue
    destroy_render! @issue
  end

  private

  def issue_params
    params.permit(:title, :latitude, :longitude,
                   :category, :picture, :description,
                   :risk, :coins)
  end

  def set_user
    @user = User.find_by!(user_auth_token: params[:user_auth_token])
  end

  def set_user_issue
    @issue = @user.issues.find_by!(issue_auth_token: params[:issue_auth_token]) if @user
  end

  def set_issue
    @issue = Issue.find_by!(issue_auth_token: params[:issue_auth_token])
  end

  def set_current_user
    auth_command = AuthorizeApiRequest.call(request.headers)
    @current_user = auth_command.result if auth_command.success?
  end

  def filter_issues(issues)
    issues = issues.where(category: params[:categories]) if params.key?('categories')
    issues = issues.where(resolved: params[:resolved] == 'true') if params.key?('resolved')
    issues = issues.where(risk: params[:risk] == 'true') if params.key?('risk')
    issues = issues.where('latitude <= ?', params[:lat_max].to_f) if params.key?('lat_max')
    issues = issues.where('longitude <= ?', params[:lng_max].to_f) if params.key?('lng_max')
    issues = issues.where('latitude >= ?', params[:lat_min].to_f) if params.key?('lat_min')
    issues = issues.where('longitude >= ?', params[:lng_min].to_f) if params.key?('lng_min')
    issues
  end
  
  def increase_progresses
    @user.increase_events_progress 'issue'
  end
end