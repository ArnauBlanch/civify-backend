require 'test_helper'
require 'timecop'
# Resolve controller test
class ResolveControllerTest < ActionDispatch::IntegrationTest
  RESOLVE_IN = 10

  def setup
    setup_user
    setup_issue
  end

  # POST /issues/:issue_auth_token/resolve
  test 'resolution deleted' do
    @issue.users_resolving << @user
    Timecop.freeze(Date.today + 60)
    post "/issues/#{@issue.issue_auth_token}/resolve",
         headers: authorization_header(@password, @user.username),
         params: { user: @user.user_auth_token }, as: :json
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal 'Resolution deleted', body['message']
    assert !@issue.resolutions.exists?(@user.id)
    assert_equal @issue.resolved_votes - 1,
                 Issue.find_by(id: @issue.id).resolved_votes
  end

  # POST /issues/:issue_auth_token/resolve
  test 'resolution added' do
    post "/issues/#{@issue.issue_auth_token}/resolve",
         headers: authorization_header(@password, @user.username),
         params: { user: @user.user_auth_token }, as: :json
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal 'Resolution added', body['message']
    assert @issue.users_resolving.exists?(@user.id)
    assert_equal @issue.resolved_votes + 1,
                 Issue.find_by(id: @issue.id).resolved_votes
  end

  test "one user can resolve other's user issue" do
    setup_user(username: 'self')
    post "/issues/#{@issue.issue_auth_token}/resolve",
         headers: authorization_header(@password, @user.username),
         params: { user: @user.user_auth_token }, as: :json
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal 'Resolution added', body['message']
    assert @issue.users_resolving.exists?(@user.id)
    assert_equal @issue.resolved_votes + 1,
                 Issue.find_by(id: @issue.id).resolved_votes
  end

  # POST /issues/:issue_auth_token/resolve
  test 'issue not found' do
    post "/issues/1234/resolve?user=#{@user.user_auth_token}",
         headers: authorization_header(@password, @user.username)
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal 'Issue not found', body['message']
  end

  # POST /issues/:issue_auth_token/resolve
  test 'user not found' do
    post "/issues/#{@issue.issue_auth_token}/resolve?user=user",
         headers: authorization_header(@password, @user.username)
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal 'User not found', body['message']
  end

  test "Issue resolved automatically" do
    old_votes = RESOLVE_IN - 1
    @issue.update(resolved_votes: old_votes)
    setup_user(username: 'resolver')
    post "/issues/#{@issue.issue_auth_token}/resolve",
         headers: authorization_header(@password, @user.username),
         params: { user: @user.user_auth_token }, as: :json
    @issue.reload
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal 'Resolution added', body['message']
    assert @issue.users_resolving.exists?(@user.id)
    assert_equal old_votes + 1,
                 Issue.find_by(id: @issue.id).resolved_votes
    assert_equal true, @issue.resolved
    post "/issues/#{@issue.issue_auth_token}/resolve",
         headers: authorization_header(@password, @user.username),
         params: { user: @user.user_auth_token }, as: :json
    assert_response :bad_request
    assert_response_body 'Could not do the resolution', :message

  end

  test 'cant resolve and mark unresolved after less than 1 minute' do
    post "/issues/#{@issue.issue_auth_token}/resolve",
         headers: authorization_header(@password, @user.username),
         params: { user: @user.user_auth_token }, as: :json
    assert_response :ok
    post "/issues/#{@issue.issue_auth_token}/resolve",
         headers: authorization_header(@password, @user.username),
         params: { user: @user.user_auth_token }, as: :json
    assert_response :bad_request
    # assert_response_body 'Confirmation was done less than 24 hours ago', :message
  end
end
