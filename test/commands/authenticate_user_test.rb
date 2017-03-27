require 'test_helper'

class AuthenticateUserTest < ActiveSupport::TestCase
  def setup
    @user = User.create(username: 'test',
                        email: 'test@test.com',
                        password_digest: '1234')
  end

  test 'login existing user with username succeeds' do
    auth_command = AuthenticateUser.call @user.password_digest, @user.username
    assert auth_command.success?
  end

  test 'login existing user with email succeeds' do
    auth_command = AuthenticateUser.call @user.password_digest, nil, @user.email
    assert auth_command.success?
  end

  test 'login fails when existing user by username has invalid credentials' do
    auth_command = AuthenticateUser.call 'invalid_password', @user.username
    assert_not auth_command.success?
    assert_equal 'Invalid credentials',
                 auth_command.errors[:invalid_credentials][0]
  end

  test 'login fails when existing user by email has invalid credentials' do
    auth_command = AuthenticateUser.call 'invalid_password', nil, @user.email
    assert_not auth_command.success?
    assert_equal 'Invalid credentials',
                 auth_command.errors[:invalid_credentials][0]
  end

  test 'login fails when user by username not exits' do
    auth_command = AuthenticateUser.call @user.password_digest, 'unknown'
    assert_not auth_command.success?
    assert_equal 'User not exists', auth_command.errors[:not_found][0]
  end

  test 'login fails when user by email not exits' do
    auth_command = AuthenticateUser.call @user.password_digest, nil, 'unknown'
    assert_not auth_command.success?
    assert_equal 'User not exists', auth_command.errors[:not_found][0]
  end

  test 'login fails when password is not provided' do
    auth_command = AuthenticateUser.call nil, @user.username
    assert_not auth_command.success?
    assert_equal 'password must be provided',
                 auth_command.errors[:missing_parameters][0]
  end

  test 'login fails when username nor email are provided' do
    auth_command = AuthenticateUser.call @user.password_digest
    assert_not auth_command.success?
    assert_equal 'username or email must be provided',
                 auth_command.errors[:missing_parameters][0]
  end
end
