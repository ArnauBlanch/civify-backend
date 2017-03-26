class IssuesController < ApplicationController
  before_action :set_user
  before_action :set_user_issue, only: [:show, :update, :destroy]

  def index
    json_response(@user.issues)
  end

  def show
    json_response(@issue)
  end

  def create
    @issue_created = @user.issues.create!(issue_params)
    json_response(@issue_created, :created)
  end

  def update
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
    params.permit(:id, :user_id, :title, :latitude, :longitude,
                  :category, :picture, :description,
                  :risk, :resolved_votes, :confirm_votes,
                  :reports)
  end

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_user_issue
    @issue = @user.issues.find_by!(id: params[:id]) if @user
  end
end