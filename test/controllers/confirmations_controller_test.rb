require 'test_helper'
require 'timecop'
# Confirmations controller test
class ConfirmationsControllerTest < ActionDispatch::IntegrationTest

  def setup
    setup_user
    setup_issue
  end

  test 'confirm issue by auth user' do
    post_confirm_issue
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal "Issue with auth token #{@issue.issue_auth_token} "\
    "confirmed by User with auth token #{@user.user_auth_token}",body['message']
    assert @issue.users_confirming.exists?(@user.id)
    assert @user.confirmed_issues.exists?(@issue.id)
    get "/issues/#{@issue.issue_auth_token}",
        headers: authorization_header(@password, @user.username)
    assert_response :ok
    body = JSON.parse(response.body)
    assert body['confirmed_by_auth_user']
    assert_equal 1, body['confirm_votes']
  end

  test 'confirm issue by user param' do
    post_confirm_issue @user
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal "Issue with auth token #{@issue.issue_auth_token} "\
    "confirmed by User with auth token #{@user.user_auth_token}",body['message']
    assert @issue.users_confirming.exists?(@user.id)
    assert @user.confirmed_issues.exists?(@issue.id)
    get "/issues/#{@issue.issue_auth_token}",
        headers: authorization_header(@password, @user.username)
    assert_response :ok
    body = JSON.parse(response.body)
    assert body['confirmed_by_auth_user']
    assert_equal 1, body['confirm_votes']
  end

  test "one user can confirm other's user issue" do
    setup_user(username: 'self')
    post_confirm_issue
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal "Issue with auth token #{@issue.issue_auth_token} "\
    "confirmed by User with auth token #{@user.user_auth_token}", body['message']
  end

  test 'unconfirm in less than 1 minute' do
    post_confirm_issue
    post_confirm_issue
    assert_response :bad_request
    body = JSON.parse(response.body)
    assert_equal "Confirmation was done less than 24 hours ago", body['message']
    get "/issues/#{@issue.issue_auth_token}",
        headers: authorization_header(@password, @user.username)
    assert_response :ok
    body = JSON.parse(response.body)
    assert body['confirmed_by_auth_user']
    assert_equal 1, body['confirm_votes']
  end

  test 'unconfirm issue by auth user' do
    post_confirm_issue
    Timecop.freeze(Date.today + 60)
    post_confirm_issue
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal "Issue with auth token #{@issue.issue_auth_token} "\
    "confirmed/unconfirmed by User with auth token #{@user.user_auth_token}", body['message']
    get "/issues/#{@issue.issue_auth_token}",
        headers: authorization_header(@password, @user.username)
    assert_response :ok
    body = JSON.parse(response.body)
    assert_not body['confirmed_by_auth_user']
    assert_equal 0, body['confirm_votes']
  end

  test 'unconfirm issue by user param' do
    post_confirm_issue @user
    Timecop.freeze(Date.today + 60)
    post_confirm_issue @user
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal "Issue with auth token #{@issue.issue_auth_token} "\
    "confirmed/unconfirmed by User with auth token #{@user.user_auth_token}",body['message']
    get "/issues/#{@issue.issue_auth_token}",
        headers: authorization_header(@password, @user.username)
    assert_response :ok
    body = JSON.parse(response.body)
    assert_not body['confirmed_by_auth_user']
    assert_equal 0, body['confirm_votes']
  end

  test 'user not found' do
    post "/issues/#{@issue.issue_auth_token}/confirm?user_auth_token=fake",
         headers: authorization_header(@password, @user.username)
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal'User not found', body['message']
  end

  test 'issue not found' do
    post "/issues/fakeIssue/confirm?user_auth_token=#{@user.user_auth_token}",
         headers: authorization_header(@password, @user.username)
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal'Issue not found', body['message']
  end

end
