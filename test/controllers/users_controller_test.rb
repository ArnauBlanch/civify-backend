require 'test_helper'

# Tests user controller
class UsersControllerTest < ActionDispatch::IntegrationTest
  test 'get all users' do
    setup_user
    get '/users', headers: authorization_header(@password, @user.username)
    assert_response :ok
    assert_equal User.all.to_json(except: json_exclude), response.body
  end

  test 'get user by auth token' do
    setup_user
    token = @user.user_auth_token
    get '/users/' + token, headers: authorization_header(@password, @user.username)
    assert_response :ok
    assert_equal @user.to_json(except: json_exclude), response.body
  end

  test 'valid create request' do
    post '/users', params: {
      username: 'foo', email: 'foo@bar.com',
      first_name: 'Foo', last_name: 'Bar',
      password: 'mypass', password_confirmation: 'mypass'
    }, as: :json
    assert_response :created # test status code
    user = User.find_by(username: 'foo') # test user creation
    assert_not_nil user
    assert_response_body({ message: 'User created', user: user })
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
    assert_response_body({ message: 'User created', user: user })
  end

  test 'invalid create request' do
    post '/users', params: {
      email: 'foo@bar.com',
      first_name: 'Foo', last_name: 'Bar',
      password: 'mypass', password_confirmation: 'mypass'
    }, as: :json
    assert_response :bad_request # test status code
    assert_response_body_message "Username can't be blank"
  end

  test 'invalid admin create request' do
    post '/users', params: {
        username: 'foo', email: 'foo@bar.com',
        first_name: 'Foo', last_name: 'Bar', kind: 'admin',
        password: 'mypass', password_confirmation: 'mypass'
    }, as: :json
    assert_response :unauthorized # test status code
    assert_response_body_message 'Admin users cannot be created this way for security reasons'
  end

  test 'valid destroy request' do
    setup_user
    token = @user.user_auth_token
    delete '/users/' + token, headers: authorization_header(@password, @user.username)
    assert_response :ok
    assert_nil User.find_by(user_auth_token: token)
    assert_response_body_message 'User deleted'
  end

  test 'invalid destroy request' do
    setup_user
    delete '/users/123', headers: authorization_header(@password, @user.username)
    assert_response :not_found
    assert_response_body_message 'User not found'
  end

  def json_exclude
    [:id, :password_digest, :email, :created_at, :updated_at, :xp]
  end
end
