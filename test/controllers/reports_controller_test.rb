require 'test_helper'
# Reports controller test
class ReportsControllerTest < ActionDispatch::IntegrationTest
  def setup
    setup_user
    setup_issue
  end

  test 'report issue by auth user' do
    post "/issues/#{@issue.issue_auth_token}/report",
         headers: authorization_header(@password, @user.username)
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal "Issue with auth token #{@issue.issue_auth_token} "\
    "reported by User with auth token #{@user.user_auth_token}",body['message']
    assert @issue.users_reporting.exists?(@user.id)
    assert @user.reported_issues.exists?(@issue.id)
    get "/issues/#{@issue.issue_auth_token}",
        headers: authorization_header(@password, @user.username)
    assert_response :ok
    body = JSON.parse(response.body)
    assert body['reported_by_auth_user']
    assert_equal 1, body['num_reports']
  end

  test 'report issue by user param' do
    post "/issues/#{@issue.issue_auth_token}/report?user_auth_token=#{@user.user_auth_token}",
         headers: authorization_header(@password, @user.username)
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal "Issue with auth token #{@issue.issue_auth_token} "\
    "reported by User with auth token #{@user.user_auth_token}",body['message']
    assert @issue.users_reporting.exists?(@user.id)
    assert @user.reported_issues.exists?(@issue.id)
    get "/issues/#{@issue.issue_auth_token}",
        headers: authorization_header(@password, @user.username)
    assert_response :ok
    body = JSON.parse(response.body)
    assert body['reported_by_auth_user']
    assert_equal 1, body['num_reports']
  end

  test 'unreport issue by auth user' do
    post "/issues/#{@issue.issue_auth_token}/report",
         headers: authorization_header(@password, @user.username)
    post "/issues/#{@issue.issue_auth_token}/report",
         headers: authorization_header(@password, @user.username)
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal "Issue with auth token #{@issue.issue_auth_token} "\
    "unreported by User with auth token #{@user.user_auth_token}", body['message']
    assert_not @issue.users_reporting.exists?(@user.id)
    assert_not@user.reported_issues.exists?(@issue.id)
    get "/issues/#{@issue.issue_auth_token}",
        headers: authorization_header(@password, @user.username)
    assert_response :ok
    body = JSON.parse(response.body)
    assert_not body['reported_by_auth_user']
    assert_equal 0, body['num_reports']
  end

  test 'unreport issue by user param' do
    post "/issues/#{@issue.issue_auth_token}/report?user_auth_token=#{@user.user_auth_token}",
         headers: authorization_header(@password, @user.username)
    post "/issues/#{@issue.issue_auth_token}/report?user_auth_token=#{@user.user_auth_token}",
         headers: authorization_header(@password, @user.username)
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal "Issue with auth token #{@issue.issue_auth_token} "\
    "unreported by User with auth token #{@user.user_auth_token}",body['message']
    assert_not @issue.users_reporting.exists?(@user.id)
    assert_not@user.reported_issues.exists?(@issue.id)
    get "/issues/#{@issue.issue_auth_token}",
        headers: authorization_header(@password, @user.username)
    assert_response :ok
    body = JSON.parse(response.body)
    assert_not body['reported_by_auth_user']
    assert_equal 0, body['num_reports']
  end

  test 'user not found' do
    post "/issues/#{@issue.issue_auth_token}/report?user_auth_token=fake",
         headers: authorization_header(@password, @user.username)
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal"Doesn't exists record", body['message']
  end

  test 'issue not found' do
    post "/issues/fakeIssue/report?user_auth_token=#{@user.user_auth_token}",
         headers: authorization_header(@password, @user.username)
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal"Doesn't exists record", body['message']
  end
end