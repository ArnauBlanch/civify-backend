require 'test_helper'

# Tests the User model
class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(username: 'ivan1234', email: 'ivan1234@example.com',
                     first_name: 'Ivan', last_name: 'de Mingo Guerrero',
                     password: 'pass1234', password_confirmation: 'pass1234')
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
end
