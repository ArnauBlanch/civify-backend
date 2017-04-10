require 'test_helper'

class ResolveControllerTest < ActionDispatch::IntegrationTest
  def setup
    setup_user
    setup_issue
  end

  # GET /issues/:issue_auth_token/resolve?user=example
  test 'resolution does not exists' do
    get "/issues/#{@issue.issue_auth_token}/resolve?user=#{@user.username}",
        headers: authorization_header(@password, @user.username)
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal 'Resolution does not exist', body['message']
  end

  # GET /issues/:issue_auth_token/resolve?user=example
  test 'resolution exists' do
    @user.resolutions << @issue
    get "/issues/#{@issue.issue_auth_token}/resolve?user=#{@user.username}",
        headers: authorization_header(@password, @user.username)
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal 'Resolution exists', body['message']
  end

  # POST /issues/:issue_auth_token/resolve
  test 'resolution already exists' do
    @user.resolutions << @issue
    post "/issues/#{@issue.issue_auth_token}/resolve",
         headers: authorization_header(@password, @user.username),
         params: { user: @user.username }, as: :json
    assert_response :bad_request
    body = JSON.parse(response.body)
    assert_equal 'Resolution already exists', body['message']
  end

  # POST /issues/:issue_auth_token/resolve
  test 'resolution done' do
    post "/issues/#{@issue.issue_auth_token}/resolve",
         headers: authorization_header(@password, @user.username),
         params: { user: @user.username }, as: :json
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal 'Resolution done', body['message']
    assert @user.resolutions.exists?(@issue.id)
  end

  # GET /issues/:issue_auth_token/resolve?user=example
  test 'issue not found' do
    get "/issues/1234/resolve?user=#{@user.username}",
        headers: authorization_header(@password, @user.username)
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal 'Issue not found', body['message']
  end

  # GET /issues/:issue_auth_token/resolve?user=example
  test 'user not found' do
    get "/issues/#{@issue.issue_auth_token}/resolve?user=user",
        headers: authorization_header(@password, @user.username)
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal 'User not found', body['message']
  end
end
