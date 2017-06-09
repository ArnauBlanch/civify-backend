require 'test_helper'

class CanCreateIssueControllerTest < ActionDispatch::IntegrationTest

  def setup
    setup_user
  end

  test 'level 1 user' do
    create_issues 1
    can_create_issue_request @user, :unauthorized
  end

  private

  def create_issues(level)
    i = 0
    while i < (1.5 * level).ceil
      can_create_issue_request @user, :ok
      create_issue @user
      @user.update(xp: 0)
      i += 1
    end
  end

  def create_issue(user)
    post "/users/#{user.user_auth_token}/issues", params: {
        title: 'sample issue', latitude: 76.4,
        longitude: 38.2, category: 'arbolada',
        description: 'desc', picture: sample_image_hash,
        risk: false
    }, headers: authorization_header(@password, user.username)
    assert_response :created
    user.reload
  end

  def can_create_issue_request(user, response)
    get '/can_create_issue', headers: authorization_header(@password, user.username)
    assert_response response
    user.reload
  end
end
