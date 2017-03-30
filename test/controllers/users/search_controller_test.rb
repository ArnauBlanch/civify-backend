require 'test_helper'

class Users::SearchControllerTest < ActionDispatch::IntegrationTest
  setup do
    User.create(username: 'foo', email: 'foo@bar.com',
                first_name: 'Foo', last_name: 'Bar',
                password: 'mypass', password_confirmation: 'mypass')
  end

  test 'valid username search' do
    post '/users/search', params: { username: 'foo' }, as: :json
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal 'User exists', body['message']
  end

  test 'valid email search' do
    post '/users/search', params: { email: 'foo@bar.com' }, as: :json
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal 'User exists', body['message']
  end

  test 'invalid search' do
    post '/users/search', params: {}, as: :json
    assert_response :bad_request
    body = JSON.parse(response.body)
    assert_equal 'Username or email must be provided', body['message']
  end

  test 'non-existing username' do
    post '/users/search', params: { username: 'foo1' }, as: :json
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal 'User not exists', body['message']
  end

  test 'non-existing email' do
    post '/users/search', params: { username: 'foo1@bar1.com' }, as: :json
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal 'User not exists', body['message']
  end
end
