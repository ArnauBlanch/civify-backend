require 'test_helper'

class Users::AccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Clear users table
    User.delete_all
  end

  test 'valid create request' do
    post '/users/accounts', params: {
      username: 'foo', email: 'foo@bar.com',
      first_name: 'Foo', last_name: 'Bar',
      password: 'mypass', password_confirmation: 'mypass'
    }
    assert_response :created # test status code
    assert_not_nil User.find_by(username: 'foo') # test user creation
    body = JSON.parse(response.body)
    assert_equal 'foo', body['username'] # test response body
    teardown
  end

  test 'invalid create request' do
    post '/users/accounts', params: {
      username: ' ', email: 'foo@bar.com',
      first_name: 'Foo', last_name: 'Bar',
      password: 'mypass', password_confirmation: 'mypass'
    }
    assert_response :unprocessable_entity
    teardown
  end

  test 'valid find by existing username request' do
    create_user
    get '/users/accounts', params: { find_by: 'username', value: 'foo' }
    # test status code
    assert_response :ok
    teardown
  end

  test 'valid find by non-existing username request' do
    get '/users/accounts', params: { find_by: 'username', value: ' ' }
    # test status code
    assert_response :not_found
  end

  test 'valid find by existing email request' do
    create_user
    get '/users/accounts', params: { find_by: 'email',
                                     value: 'foo@bar.com' }
    # test status code
    assert_response :ok
    teardown
  end

  test 'valid find by non-existing email request' do
    get '/users/accounts', params: { find_by: 'email', value: ' ' }
    # test status code
    assert_response :not_found
  end

  test 'invalid find by request' do
    get '/users/accounts', params: { find_by: ' ', value: 'foo' }
    # test status code
    assert_response :unprocessable_entity
  end

  private

  def create_user
    User.create(username: 'foo', email: 'foo@bar.com',
                first_name: 'Foo', last_name: 'Bar',
                password: 'mypass', password_confirmation: 'mypass')
  end

  def teardown
    # Clear users table
    User.delete_all
  end
end
