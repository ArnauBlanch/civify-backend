require 'test_helper'

# Login is state-less (no sessions, no logouts)
class AuthenticationControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create(username: 'test',
                        email: 'test@test.com',
                        password_digest: '1234')
  end

  test 'login existing user with username succeeds' do
    login @user.username, nil
    assert_login_succeeds
  end

  test 'login existing user with email succeeds' do
    login nil
    assert_login_succeeds
  end

  test 'login fails when user not exits' do
    login 'unknown', 'unknown@unknown.com'
    assert_error :not_found, 'User not exists'
  end

  test 'login fails when password is wrong' do
    login @user.username, @user.email, 'wrong password'
    assert_error :unauthorized, 'Invalid credentials'
  end

  test 'login fails when username nor email are provided' do
    login nil, nil
    assert_error :bad_request, 'username or email must be provided'
  end

  test 'login fails when password is not provided' do
    login nil, nil, nil
    assert_error :bad_request, 'password must be provided'
  end

  test 'multiple accounts logged in simultaneously' do
    login
    auth_token1 = assert_login_succeeds
    @user = User.create(username: 'test2',
                        email: 'test2@test.com',
                        password_digest: '4321')
    login
    auth_token2 = assert_login_succeeds
    assert_not_equal auth_token1, auth_token2
  end

  def login(username = @user.username,
            email = @user.email,
            password = @user.password_digest)
    post '/login', params: {
      username: username,
      email: email,
      password: password
    }, as: :json
  end

  def assert_login_succeeds
    assert_response :ok
    auth_command = AuthenticateUser.call @user.password_digest, @user.username
    auth_token = auth_command.result
    expected_response = { auth_token: auth_token }.to_json
    assert_equal expected_response, response.body
    auth_token
  end

  def assert_error(status, msg)
    assert_response status
    expected_response = { error: msg }.to_json
    assert_equal expected_response, response.body
  end
end
