require 'test_helper'

# Tests users controller
class UserControllerTest < ActionDispatch::IntegrationTest
  test 'valid request should get a created (201) status code' do
    post '/users', params: {
      username: 'ivan1234', email: 'ivan1234@example.com',
      first_name: 'Ivan', last_name: 'de Mingo Guerrero',
      password: 'pass1234', password_confirmation: 'pass1234'
    }
    assert_response 201
  end

  test 'valid request should create a user' do
    post '/users', params: {
      username: 'ivan1234', email: 'ivan1234@example.com',
      first_name: 'Ivan', last_name: 'de Mingo Guerrero',
      password: 'pass1234', password_confirmation: 'pass1234'
    }
    assert_not_nil User.find_by(username: 'ivan1234')
  end

  test 'invalid request should get an unprocessable entity (422) status
code' do
    post '/users', params: {
      username: ' ', email: 'ivan1234@example.com',
      first_name: 'Ivan', last_name: 'de Mingo Guerrero',
      password: 'pass1234', password_confirmation: 'pass1234'
    }
    assert_response 422
  end
end
