require 'test_helper'

# Tests user controller
class UsersControllerTest < ActionDispatch::IntegrationTest
  test 'get all users' do
    set_up
    get '/users'
    assert_response :ok
    assert_equal response.body, User.all.to_json(except: :id)
    tear_down
  end

  test 'get user by auth token' do
    set_up
    token = @user.user_auth_token
    get '/users/' + token
    assert_response :ok
    assert_equal response.body, @user.to_json(except: :id)
    tear_down
  end

  test 'valid create request' do
    post '/users', params: {
      username: 'foo', email: 'foo@bar.com',
      first_name: 'Foo', last_name: 'Bar',
      password: 'mypass', password_confirmation: 'mypass'
    }, as: :json
    assert_response :created # test status code
    assert_not_nil User.find_by(username: 'foo') # test user creation
    assert_equal response.body,
                 User.find_by(username: 'foo').to_json(except: :id)
  end

  test 'invalid create request' do
    post '/users', params: {
      email: 'foo@bar.com',
      first_name: 'Foo', last_name: 'Bar',
      password: 'mypass', password_confirmation: 'mypass'
    }, as: :json
    assert_response :bad_request # test status code
    body = JSON.parse(response.body)
    assert_equal 'User not created', body['message'] # test response body
  end

  test 'valid destroy request' do
    set_up
    token = @user.user_auth_token
    delete '/users/' + token
    assert_response :ok
    assert_nil User.find_by(user_auth_token: token)
    body = JSON.parse(response.body)
    assert_equal 'User deleted', body['message']
  end

  test 'invalid destroy request' do
    delete '/users/123'
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal 'User not found', body['message']
  end

  def set_up
    @user = User.create(username: 'foo', email: 'foo@bar.com',
                        first_name: 'Foo', last_name: 'Bar',
                        password: 'mypass', password_confirmation: 'mypass')
  end

  def tear_down
    User.delete_all
  end
end
