require 'test_helper'
require 'rack/test'
require 'base64'

class IssuesControllerTest < ActionDispatch::IntegrationTest

  def setup
    setup_user
    setup_issue
  end

  test 'get all user issues request' do
    get "/users/#{@user.user_auth_token}/issues",
        headers: authorization_header(@password, @user.username)
    assert_response :ok
    assert_equal response.body, @user.issues.to_json
  end

  test 'get user issue by token request' do
    get "/users/#{@user.user_auth_token}/issues/#{@issue.issue_auth_token}",
        headers: authorization_header(@password, @user.username)
    assert_response :ok
  end

  test 'create user issue valid request' do
    post "/users/#{@user.user_auth_token}/issues", params: {
          title: 'sample issue', latitude: 76.4,
          longitude: 38.2, category: 'arbolada',
          description: 'desc', picture: sample_image_hash,
          risk: false, resolved_votes: 564,
          confirm_votes: 0, reports: 0
    }, headers: authorization_header(@password, @user.username)
    assert_response :created
    issue = Issue.find_by(title: 'sample issue')
    assert_not_nil issue
  end

  test 'create user issue invalid request' do
    post "/users/#{@user.user_auth_token}/issues", params: {
        latitude: 76.4,
        longitude: 38.2, category: 'arbolada',
        description: 'desc', picture: sample_image_hash,
        risk: true, resolved_votes: 564,
        confirm_votes: 23, reports: 23
    }, headers: authorization_header(@password, @user.username)
    assert_response :bad_request
    body = JSON.parse(response.body)
    assert_equal "Validation failed: Title can't be blank", body['message']
  end

  test 'destroy user issue valid request' do
    delete "/users/#{@user.user_auth_token}/issues/#{@issue.issue_auth_token}",
           headers: authorization_header(@password, @user.username)
    assert_response :no_content
    assert_nil Issue.find_by(issue_auth_token: @issue.issue_auth_token)
  end

  test 'destroy user issue invalid request' do
    delete "/users/#{@user.user_auth_token}/issues/123",
           headers: authorization_header(@password, @user.username)
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal "Doesn't exists record", body['message']
  end

  test 'update user issue valid request' do
    patch "/users/#{@user.user_auth_token}/issues/#{@issue.issue_auth_token}", params: {
        category: 'nuclear'
    }, headers: authorization_header(@password, @user.username)
    assert_response :ok
    @issue.reload
    assert_equal @issue.category, 'nuclear'
  end

  test 'update user issue valid request but ignored values' do
    patch "/users/#{@user.user_auth_token}/issues/#{@issue.issue_auth_token}", params: {
        title: 'title updated',
        titlefake: 'no'
    }, headers: authorization_header(@password, @user.username)
    assert_response :ok
    @issue.reload
    assert_equal @issue.title, 'title updated'
  end

  test 'get issue' do
    get "/issues/#{@issue.issue_auth_token}",
        headers: authorization_header(@password, @user.username)
    assert_response :ok
  end

  test 'destroy issue valid request' do
    delete "/issues/#{@issue.issue_auth_token}",
           headers: authorization_header(@password, @user.username)
    assert_response :no_content
    assert_nil Issue.find_by(issue_auth_token: @issue.issue_auth_token)
  end

  test 'destroy issue invalid request' do
    delete '/issues/123',
           headers: authorization_header(@password, @user.username)
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal "Doesn't exists record", body['message']
  end
  
  test 'update issue valid request' do
    patch "/issues/#{@issue.issue_auth_token}", params: {
        category: 'nuclear'
    }, headers: authorization_header(@password, @user.username)
    assert_response :ok
    @issue.reload
    assert_equal @issue.category, 'nuclear'
  end

  test 'update issue valid request but ignored' do
    patch "/issues/#{@issue.issue_auth_token}", params: {
        title: 'title updated',
        titlefake: 'no'
    }, headers: authorization_header(@password, @user.username)
    assert_response :ok
    @issue.reload
    assert_equal @issue.title, "title updated"
  end

  test 'create user issue image bad format' do
    post "/users/#{@user.user_auth_token}/issues", params: {
        latitude: 76.4,
        longitude: 38.2, category: 'arbolada',
        description: 'desc', picture: 'nil',
        risk: true, resolved_votes: 564,
        confirm_votes: 23, reports: 23
    }, headers: authorization_header(@password, @user.username)
    assert_response :bad_request
    body = JSON.parse(response.body)
    assert_equal 'Image bad format', body['error']
  end

  test 'get user issue obtains confirmed by authenticated user' do
    get "/users/#{@user.user_auth_token}/issues/#{@issue.issue_auth_token}",
        headers: authorization_header(@password, @user.username)
    assert_response :ok
    body = JSON.parse(response.body)
    assert_not body['confirmed_by_auth_user']
    post "/issues/#{@issue.issue_auth_token}/confirm",
         headers: authorization_header(@password, @user.username)
    get "/users/#{@user.user_auth_token}/issues/#{@issue.issue_auth_token}",
        headers: authorization_header(@password, @user.username)
    assert_response :ok
    body = JSON.parse(response.body)
    assert body['confirmed_by_auth_user']
  end
end
