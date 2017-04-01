require 'test_helper'

class AuthenticateUserTest < ActiveSupport::TestCase
  def setup
    setup_user
  end

  test 'login existing user with all parameters succeeds' do
    assert authenticate.success?
  end

  test 'login existing user with username succeeds' do
    auth_command = authenticate @password, @user.username, nil
    assert auth_command.success?
  end

  test 'login existing user with email succeeds' do
    auth_command = authenticate @password, nil, @user.email
    assert auth_command.success?
  end

  test 'login fails when existing user by username has invalid credentials' do
    auth_command = authenticate 'invalid_password', @user.username, nil
    assert_error auth_command, :invalid_credentials, 'Invalid credentials'
  end

  test 'login fails when existing user by email has invalid credentials' do
    auth_command = authenticate 'invalid_password', nil, @user.email
    assert_error auth_command, :invalid_credentials, 'Invalid credentials'
  end

  test 'login fails when user by username not exits' do
    auth_command = authenticate @password, 'unknown', nil
    assert_error auth_command, :not_found, 'User not exists'
  end

  test 'login fails when user by email not exits' do
    auth_command = authenticate @password, nil, 'unknown'
    assert_error auth_command, :not_found, 'User not exists'
  end

  test 'login fails when password is not provided' do
    auth_command = authenticate nil
    assert_error auth_command, :missing_parameters, 'password must be provided'
  end

  test 'login fails when username nor email are provided' do
    auth_command = authenticate @password, nil, nil
    assert_error auth_command, :missing_parameters, 'username or email must be provided'
  end

  def authenticate(password = @password,
                   username = @user.username,
                   email = @user.email)
    AuthenticateUser.call password, username, email
  end

  def assert_error(auth_command, error, msg)
    assert_not auth_command.success?
    assert_equal msg,auth_command.errors[error][0]
  end
end
