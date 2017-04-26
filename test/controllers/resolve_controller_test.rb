require 'test_helper'
# Resolve controller test
class ResolveControllerTest < ActionDispatch::IntegrationTest
  def setup
    setup_user
    setup_issue
  end

  # POST /issues/:issue_auth_token/resolve
  test 'resolution deleted' do
    @issue.resolutions << @user
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
    assert @issue.resolutions.exists?(@user.id)
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
end
