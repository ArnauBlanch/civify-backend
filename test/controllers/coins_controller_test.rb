require 'test_helper'

class CoinsControllerTest < ActionDispatch::IntegrationTest
  def setup
    setup_user
  end

  test 'user not found' do
    post "/users/1234/coins",
         headers: authorization_header(@password, @user.username),
         params: { coins: 5 }, as: :json
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal 'User not found', body['message']
  end

  test 'coins not specified' do
    post "/users/#{@user.user_auth_token}/coins",
         headers: authorization_header(@password, @user.username)
    assert_response :bad_request
    body = JSON.parse(response.body)
    assert_equal 'Specify the number of coins', body['message']
  end

  test 'coins must be positive' do
    post "/users/#{@user.user_auth_token}/coins",
         headers: authorization_header(@password, @user.username),
         params: { coins: -5 }, as: :json
    assert_response :bad_request
    body = JSON.parse(response.body)
    assert_equal 'Coins must be greater than or equal to 0', body['message']
  end

  test 'valid add coins' do
    before_coins = @user.coins
    post "/users/#{@user.user_auth_token}/coins",
         headers: authorization_header(@password, @user.username),
         params: { coins: 5 }, as: :json
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal before_coins + 5, body['coins']
    assert_equal before_coins + 5, User.find(@user.id).coins
  end
end
