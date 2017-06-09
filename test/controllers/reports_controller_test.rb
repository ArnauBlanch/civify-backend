require 'test_helper'
require 'timecop'
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
    "reported/unreported by User with auth token #{@user.user_auth_token}", body['message']
    assert @issue.users_reporting.exists?(@user.id)
    assert @user.reported_issues.exists?(@issue.id)
    get "/issues/#{@issue.issue_auth_token}",
        headers: authorization_header(@password, @user.username)
    assert_response :ok
    body = JSON.parse(response.body)
    assert body['reported_by_auth_user']
    assert_equal 1, body['num_reports']
  end

  test 'cant report issue if less than 1 minute after last report' do
    post "/issues/#{@issue.issue_auth_token}/report",
         headers: authorization_header(@password, @user.username)
    assert_response :ok
    post "/issues/#{@issue.issue_auth_token}/report",
         headers: authorization_header(@password, @user.username)
    assert_response :bad_request
    # assert_response_body 'Report was done less than 24 hours ago', :message
    get "/issues/#{@issue.issue_auth_token}",
        headers: authorization_header(@password, @user.username)
    assert_response :ok
    assert_response_body 1, :num_reports
    assert_response_body true, :reported_by_auth_user

  end

  test "one user can report other's user issue" do
    setup_user(username: 'self')
    post "/issues/#{@issue.issue_auth_token}/report",
         headers: authorization_header(@password, @user.username)
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal "Issue with auth token #{@issue.issue_auth_token} "\
    "reported/unreported by User with auth token #{@user.user_auth_token}", body['message']
  end

  test 'report issue by user param' do
    post "/issues/#{@issue.issue_auth_token}/report?user_auth_token=#{@user.user_auth_token}",
         headers: authorization_header(@password, @user.username)
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal "Issue with auth token #{@issue.issue_auth_token} "\
    "reported/unreported by User with auth token #{@user.user_auth_token}",body['message']
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
    Timecop.freeze(Date.today + 60)
    post "/issues/#{@issue.issue_auth_token}/report",
         headers: authorization_header(@password, @user.username)
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal "Issue with auth token #{@issue.issue_auth_token} "\
    "reported/unreported by User with auth token #{@user.user_auth_token}", body['message']
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
    Timecop.freeze(Date.today + 60)
    post "/issues/#{@issue.issue_auth_token}/report?user_auth_token=#{@user.user_auth_token}",
         headers: authorization_header(@password, @user.username)
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal "Issue with auth token #{@issue.issue_auth_token} "\
    "reported/unreported by User with auth token #{@user.user_auth_token}",body['message']
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
    assert_equal'User not found', body['message']
  end

  test 'issue not found' do
    post "/issues/fakeIssue/report?user_auth_token=#{@user.user_auth_token}",
         headers: authorization_header(@password, @user.username)
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal'Issue not found', body['message']
  end

  test 'reported issue 10 times deletes issue' do
    report10times
    get "/issues/#{@issue.issue_auth_token}",
        headers: authorization_header(@password, @user.username)
    assert_response :not_found
  end

  def report10times
    (1..10).each do |i|
      setup_user(username: "rep#{i}")
      post "/issues/#{@issue.issue_auth_token}/report",
           headers: authorization_header(@password, @user.username)
      assert_response :ok
    end
  end
end
