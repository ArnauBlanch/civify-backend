require 'test_helper'

class AuthenticationControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create(username: 'test',
                        email: 'test@test.com',
                        password_digest: '1234')
  end

  test 'login existing user with username succeeds' do
    post '/login', params: {
      username: @user.username,
      password: @user.password_digest
    }, as: :json
    assert_login_succeeds
  end

  test 'login existing user with email succeeds' do
    post '/login', params: {
      email: @user.email,
      password: @user.password_digest
    }, as: :json
    assert_login_succeeds
  end

  test 'login fails when user not exits' do
    post '/login', params: {
      email: 'unknown',
      password: @user.password_digest
    }, as: :json
    assert_error :not_found, 'User not exists'
  end

  test 'login fails when password is wrong' do
    post '/login', params: {
      email: @user.email,
      password: 'unknown'
    }, as: :json
    assert_error :unauthorized, 'Invalid credentials'
  end

  test 'login fails when password is not provided' do
    post '/login'
    assert_error :bad_request, 'password must be provided'
  end

  test 'login fails when username nor email are provided' do
    post '/login', params: {
      password: @user.password_digest
    }, as: :json
    assert_error :bad_request, 'username or email must be provided'
  end

  def assert_login_succeeds
    assert_response :ok
    auth_command = AuthenticateUser.call @user.password_digest, @user.username
    expected_response = { auth_token: auth_command.result }.to_json
    assert_equal expected_response, response.body
  end

  def assert_error(status, msg)
    assert_response status
    expected_response = { error: msg }.to_json
    assert_equal expected_response, response.body
  end
end
