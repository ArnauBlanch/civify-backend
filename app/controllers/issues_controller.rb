class IssuesController < ApplicationController
  before_action :set_user
  before_action :set_user_issue, only: [:show, :update, :destroy]
  before_action :fetch_picture, only: [:create, :update]

  def index
    json_response(@user.issues)
  end

  def show
    json_response(@issue)
  end

  def create
    @issue = @user.issues.build(issue_params)
    @issue.picture = @picture
    @issue.save!
    json_response(@issue, :created)
  end

  def update
    @issue.picture = @picture if @picture
    @issue.update!(issue_params)
    # 200 or 204 for update
    json_response(@issue)
  end

  def destroy
    @issue.destroy
    head :no_content
  end

  private

  def issue_params
    # maybe :id is not necessary
    params.permit(:id, :user_id, :title, :latitude, :longitude,
                  :category, :picture, :description,
                  :risk, :resolved_votes, :confirm_votes,
                  :reports)
  end

  def set_user
    @user = User.find_by!(user_auth_token: params[:user_auth_token])
  end

  def set_user_issue
    @issue = @user.issues.find_by!(issue_auth_token: params[:issue_auth_token]) if @user
  end

  def fetch_picture
    @picture = parse_image_data(params[:picture]) if params[:picture]
  end

  def parse_image_data(image_data)
    content_type = image_data[:content_type]
    image_file = Paperclip.io_adapters.for("data:#{content_type};base64,#{image_data[:content]}")
    image_file.original_filename = image_data[:filename]
    image_file
  end
end