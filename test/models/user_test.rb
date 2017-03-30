require 'test_helper'

# Tests the User model
class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(username: 'foo', email: 'foo@bar.com',
                     first_name: 'Foo', last_name: 'Bar',
                     password: 'mypass', password_confirmation: 'mypass')
  end

  test 'user should be valid' do
    assert @user.valid?
  end

  test 'username should be present' do
    @user.username = ''
    assert_not @user.valid?
  end

  test 'email should be present' do
    @user.email = ''
    assert_not @user.valid?
  end

  test 'first_name should be present' do
    @user.first_name = ''
    assert_not @user.valid?
  end

  test 'last_name should be present' do
    @user.last_name = ''
    assert_not @user.valid?
  end

  test 'username should be unique' do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test 'email should be unique' do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test 'username shouldn\'t be case sensitive (case 1)' do
    duplicate_user = @user.dup
    duplicate_user.username = duplicate_user.username.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test 'username shouldn\'t be case sensitive (case 2)' do
    duplicate_user = @user.dup
    @user.username = @user.username.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test 'email shouldn\'t be case sensitive (case 1)' do
    duplicate_user = @user.dup
    duplicate_user.email = duplicate_user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test 'email shouldn\'t be case sensitive (case 2)' do
    duplicate_user = @user.dup
    @user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test 'password should be present and non-blank' do
    @user.password = @user.password_confirmation = ' '
    assert_not @user.valid?
  end

  test 'user token is not null' do
    @user.save
    assert_not_nil @user.user_auth_token
  end
end