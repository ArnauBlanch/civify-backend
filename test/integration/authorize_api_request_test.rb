require 'test_helper'

# Testing authorized requests via tokens
# AuthorizeApiRequest and ApplicationController integration
class AuthorizeApiRequestTest < ActionDispatch::IntegrationTest

  def setup
    setup_user
  end

  test 'request authorized with valid token' do
    get '/me', headers: authorization_header(@password, @user.username)
    assert_response :ok
    assert_equal @user.to_json(except: [:id, :password_digest]), response.body
  end

  test 'request unauthorized with invalid token' do
    get '/me', headers: { authorization: 'invalid token' }
    assert_unauthorized_error 'Invalid Token'
  end

  test 'request unauthorized without token' do
    get '/me'
    assert_unauthorized_error 'Missing Authorization Token'
  end

  test 'request trying to delete other user' do
    other = @user
    setup_user('self')
    delete "/users/#{other.user_auth_token}",
           headers: authorization_header(@password, @user.username)
    assert_unauthorized_error 'Cannot update other users'
  end

  test 'request trying to delete other user being admin' do
    other = @user
    setup_user('self')
    @user.update(kind: :admin)
    delete "/users/#{other.user_auth_token}",
           headers: authorization_header(@password, @user.username)
    assert_response :success
  end

  test "request trying to update other's issue" do
    setup_issue
    other_user = @user
    other_issue = other_user.issues.first
    setup_user('self')
    post "/users/#{other_user.user_auth_token}/issues",
          headers: authorization_header(@password, @user.username)
    assert_unauthorized_error 'Cannot update other users'
    patch "/issues/#{other_issue.issue_auth_token}",
          headers: authorization_header(@password, @user.username)
    assert_unauthorized_error "Cannot update other's issues"
    delete "/users/#{other_user.user_auth_token}/issues/#{other_issue.issue_auth_token}",
          headers: authorization_header(@password, @user.username)
    assert_unauthorized_error 'Cannot update other users'
  end

  test "request trying to update other's issue being admin" do
    setup_issue
    other_user = @user
    other_issue = other_user.issues.first
    setup_user('self')
    @user.update(kind: :admin)
    post "/users/#{other_user.user_auth_token}/issues",
         headers: authorization_header(@password, @user.username)
    assert response.code != '401'
    patch "/issues/#{other_issue.issue_auth_token}",
          headers: authorization_header(@password, @user.username)
    assert response.code != '401'
    delete "/users/#{other_user.user_auth_token}/issues/#{other_issue.issue_auth_token}",
           headers: authorization_header(@password, @user.username)
    assert response.code != '401'
  end

  def assert_unauthorized_error(msg)
    assert_response :unauthorized
    expected_response = { message: msg }.to_json
    assert_equal expected_response, response.body
  end
end
