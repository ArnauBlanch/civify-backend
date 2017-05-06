require 'test_helper'

# Tests user controller
class UsersControllerTest < ActionDispatch::IntegrationTest
  test 'get all users' do
    setup_user
    get '/users', headers: authorization_header(@password, @user.username)
    assert_response :ok
    assert_equal User.all.to_json(except: json_exclude),
                 response.body
  end

  test 'get user by auth token' do
    setup_user
    token = @user.user_auth_token
    get '/users/' + token, headers: authorization_header(@password, @user.username)
    assert_response :ok
    assert_equal @user.to_json(except: json_exclude),
                 response.body
  end

  test 'valid create request' do
    post '/users', params: {
      username: 'foo', email: 'foo@bar.com',
      first_name: 'Foo', last_name: 'Bar',
      password: 'mypass', password_confirmation: 'mypass'
    }, as: :json
    assert_response :created # test status code
    assert_not_nil User.find_by(username: 'foo') # test user creation
    body = JSON.parse(response.body)
    assert_equal 'User created', body['message']
  end

  test 'valid business creation request with optional last name' do
    post '/users', params: {
        username: 'foo', email: 'foo@bar.com',
        first_name: 'Foo', kind: 'business',
        password: 'mypass', password_confirmation: 'mypass'
    }, as: :json
    assert_response :created # test status code
    user = User.find_by(username: 'foo') # test user creation
    assert_not_nil user
    assert user.business?
    body = JSON.parse(response.body)
    assert_equal 'User created', body['message']
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

  test 'invalid admin create request' do
    post '/users', params: {
        username: 'foo', email: 'foo@bar.com',
        first_name: 'Foo', last_name: 'Bar', kind: 'admin',
        password: 'mypass', password_confirmation: 'mypass'
    }, as: :json
    assert_response :unauthorized # test status code
    body = JSON.parse(response.body)
    assert_equal 'Admin users cannot be created this way for security reasons',
                 body['message'] # test response body
  end

  test 'valid destroy request' do
    setup_user
    token = @user.user_auth_token
    delete '/users/' + token, headers: authorization_header(@password, @user.username)
    assert_response :ok
    assert_nil User.find_by(user_auth_token: token)
    body = JSON.parse(response.body)
    assert_equal 'User deleted', body['message']
  end

  test 'invalid destroy request' do
    setup_user
    delete '/users/123', headers: authorization_header(@password, @user.username)
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal 'User not found', body['message']
  end

  def json_exclude
    [:id, :password_digest, :email, :first_name, :last_name, :created_at, :updated_at]
  end
end
