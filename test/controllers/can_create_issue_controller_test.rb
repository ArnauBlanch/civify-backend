require 'test_helper'

class CanCreateIssueControllerTest < ActionDispatch::IntegrationTest

  def setup
    setup_user
  end

  test 'limited issues in one day' do
    now = Time.now
    Timecop.freeze(now)
    create_issues @user.level
    can_create_issue_request @user, :unauthorized
    WAITING_TIME = 86_400 # same as in ApplicationController
    Timecop.freeze(now + WAITING_TIME.seconds)
    can_create_issue_request @user, :ok
    create_issue
    Timecop.return
  end

  private

  def create_issues(level)
    (1..(User::ISSUE_CREATION_CURVE_CONSTANT * level).ceil).each do
      can_create_issue_request @user, :ok
      pre_xp = @user.xp
      create_issue
      @user.update!(xp: pre_xp)
    end
  end

  def create_issue
    post "/users/#{@user.user_auth_token}/issues", params: {
      title: 'sample issue', latitude: 76.4,
      longitude: 38.2, category: 'arbolada',
      description: 'desc', picture: sample_image_hash,
      risk: false
    }, headers: authorization_header(@password, @user.username)
    assert_response :created
    @user.reload
  end

  def can_create_issue_request(user, status)
    get '/can_create_issue', headers: authorization_header(@password, user.username)
    assert_response status
    user.reload
  end
end
