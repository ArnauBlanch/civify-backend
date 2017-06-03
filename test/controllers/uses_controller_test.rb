require 'test_helper'

class UsesControllerTest < ActionDispatch::IntegrationTest
  def setup
    setup_user
    user1 = @user
    setup_user username: '2'
    @user2 = user1
    setup_award
    @user.exchanged_awards << @award
    @exchange = @user.exchanges.find_by!(award_id: @award.id)
  end

  test 'use an exchange' do
    post "/use?exchange_auth_token=#{@exchange.exchange_auth_token}",
         headers: authorization_header(@password, @user.username)
    assert_response :ok
    @exchange.reload
    assert @exchange.used
  end

  test "can't use an award of a different commerce" do
    post "/use?exchange_auth_token=#{@exchange.exchange_auth_token}",
         headers: authorization_header(@password, @user2.username)
    assert_response :unauthorized
    assert_not @exchange.used
  end

  test 'award already used' do
    post "/use?exchange_auth_token=#{@exchange.exchange_auth_token}",
         headers: authorization_header(@password, @user.username)
    assert_response :ok
    post "/use?exchange_auth_token=#{@exchange.exchange_auth_token}",
         headers: authorization_header(@password, @user.username)
    body = JSON.parse(response.body)
    assert_response :unauthorized
    assert_equal 'User has already used this award', body['message']
  end

  test 'exchange not found' do
    post '/use?exchange_auth_token=fakeExchange',
         headers: authorization_header(@password, @user.username)
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal'Exchange not found', body['message']
  end
end
