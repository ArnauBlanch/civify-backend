require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  test 'valid create request' do
    post '/users', params: { user: {
      username: 'foo', email: 'foo@bar.com',
      first_name: 'Foo', last_name: 'Bar',
      password: 'mypass', password_confirmation: 'mypass'
    } }, as: :json
    assert_response :created # test status code
    assert_not_nil User.find_by(username: 'foo') # test user creation
    body = JSON.parse(response.body)
    assert_equal 'User created', body['message'] # test response body
  end

  test 'invalid create request' do
    post '/users', params: { user: {
      email: 'foo@bar.com',
      first_name: 'Foo', last_name: 'Bar',
      password: 'mypass', password_confirmation: 'mypass'
    } }, as: :json
    assert_response :bad_request
    body = JSON.parse(response.body)
    assert_equal 'User not created', body['message'] # test response body
  end
end
