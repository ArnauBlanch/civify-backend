require 'test_helper'
# Confirmations controller test
class ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    setup_user
    setup_issue
  end

  test 'confirm issue by auth user' do
    post "/issues/#{@issue.issue_auth_token}/confirm",
         headers: authorization_header(@password, @user.username)
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
    post "/issues/#{@issue.issue_auth_token}/confirm?user_auth_token=#{@user.user_auth_token}",
         headers: authorization_header(@password, @user.username)
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

  test 'unconfirm issue by auth user' do
    post "/issues/#{@issue.issue_auth_token}/confirm",
         headers: authorization_header(@password, @user.username)
    post "/issues/#{@issue.issue_auth_token}/confirm",
         headers: authorization_header(@password, @user.username)
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal "Issue with auth token #{@issue.issue_auth_token} "\
    "unconfirmed by User with auth token #{@user.user_auth_token}", body['message']
    assert_not @issue.users_confirming.exists?(@user.id)
    assert_not@user.confirmed_issues.exists?(@issue.id)
    get "/issues/#{@issue.issue_auth_token}",
        headers: authorization_header(@password, @user.username)
    assert_response :ok
    body = JSON.parse(response.body)
    assert_not body['confirmed_by_auth_user']
    assert_equal 0, body['confirm_votes']
  end

  test 'unconfirm issue by user param' do
    post "/issues/#{@issue.issue_auth_token}/confirm?user_auth_token=#{@user.user_auth_token}",
         headers: authorization_header(@password, @user.username)
    post "/issues/#{@issue.issue_auth_token}/confirm?user_auth_token=#{@user.user_auth_token}",
         headers: authorization_header(@password, @user.username)
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal "Issue with auth token #{@issue.issue_auth_token} "\
    "unconfirmed by User with auth token #{@user.user_auth_token}",body['message']
    assert_not @issue.users_confirming.exists?(@user.id)
    assert_not@user.confirmed_issues.exists?(@issue.id)
    get "/issues/#{@issue.issue_auth_token}",
        headers: authorization_header(@password, @user.username)
    assert_response :ok
    body = JSON.parse(response.body)
    assert_not body['confirmed_by_auth_user']
    assert_equal 0, body['confirm_votes']
  end

  test 'user not found' do
    @user.update(kind: :admin)
    post "/issues/#{@issue.issue_auth_token}/confirm?user_auth_token=fake",
         headers: authorization_header(@password, @user.username)
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal"Doesn't exists record", body['message']
  end

  test 'issue not found' do
    post "/issues/fakeIssue/confirm?user_auth_token=#{@user.user_auth_token}",
         headers: authorization_header(@password, @user.username)
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal"Doesn't exists record", body['message']
  end
end
