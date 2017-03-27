require 'test_helper'

# Testing authorized requests via tokens
# AuthorizeApiRequest and ApplicationController integration
class AuthorizeApiRequestTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create(username: 'test',
                        email: 'test@test.com',
                        password_digest: '1234')
  end

  test 'request authorized with valid token' do
    auth_user = AuthenticateUser.call @user.password_digest, @user.username
    auth_token = auth_user.result
    get '/me', headers: { authorization: auth_token }
    assert_response :ok
    assert_equal @user.to_json(except: [:id, :password_digest]), response.body
  end

  test 'request unauthorized with invalid token' do
    get '/me', headers: { authorization: 'invalid token' }
    assert_unauthorized_error 'Invalid Token'
  end

  test 'request unauthorized without token' do
    get '/me'
    assert_unauthorized_error 'Missing Authorization Token'
  end

  def assert_unauthorized_error(msg)
    assert_response :unauthorized
    expected_response = { error: msg }.to_json
    assert_equal expected_response, response.body
  end
end
