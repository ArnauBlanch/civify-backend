class IssuesController < ApplicationController
  before_action :fetch_picture, only: [:create, :update]

  def index
    set_user
    json_response @user.issues
  end

  def show
    set_user
    set_user_issue
    @issue.current_user = current_user
    json_response @issue
  end

  def create
    set_user
    @issue = @user.issues.build(issue_params)
    @issue.picture = @picture
    @issue.save!
    json_response @issue, :created
  end

  def update
    set_user
    set_user_issue
    @issue.picture = @picture if @picture
    @issue.update!(issue_params)
    json_response @issue
  end

  def destroy
    set_user
    set_user_issue
    @issue.destroy
    head :no_content
  end

  def index_issues
    json_response Issue.all
  end

  def show_issue
    set_issue
    @issue.current_user = current_user
    json_response @issue
  end

  def update_issue
    set_issue
    @issue.picture = @picture if @picture
    @issue.update!(issue_params)
    json_response @issue
  end

  def destroy_issue
    set_issue
    @issue.destroy
    head :no_content
  end

  private

  def issue_params
    params.permit(:title, :latitude, :longitude,
                  :category, :picture, :description,
                  :risk, :resolved_votes,
                  :reports)
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

  def fetch_picture
    @picture = parse_image_data(params[:picture]) if params[:picture]
  end

  def parse_image_data(image_data)
    content_type = image_data[:content_type]
    image_file = Paperclip.io_adapters.for("data:#{content_type};base64,#{image_data[:content]}")
    image_file.original_filename = image_data[:filename]
    image_file
  rescue
    json_response({ error: 'Image bad format' }, :bad_request)
  end
end