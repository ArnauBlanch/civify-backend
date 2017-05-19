require 'test_helper'

class ExchangesControllerTest < ActionDispatch::IntegrationTest

  def setup
    award_price = 564
    setup_user(coins: award_price)
    setup_award(award_price)
  end

  test 'exchange award by auth user' do
    balance = @user.coins
    xp = @user.xp
    post "/awards/#{@award.award_auth_token}/exchange",
         headers: authorization_header(@password, @user.username)
    assert_response :ok
    assert @award.users_exchanging.exists?(@user.id)
    assert @user.exchanged_awards.exists?(@award.id)
    @user.reload
    assert_equal balance - @award.price, @user.coins
    assert_equal xp + XP.exchange_reward(@award.price), @user.xp
    rewards_hash = { 'coins' => -@award.price, 'xp' => XP.exchange_reward(@award.price) }
    assert_equal rewards_hash, JSON.parse(response.body)['rewards']
  end

  test 'cannot exchange award without enough money' do
    balance = @award.price - 1
    @user.update!(coins: balance)
    post "/awards/#{@award.award_auth_token}/exchange",
         headers: authorization_header(@password, @user.username)
    assert_response :unauthorized
    assert_equal balance, @user.coins
    body = JSON.parse(response.body)
    assert_equal"You do not have enough coins (needed $#{@award.price} but have $#{balance})",
                body['message']
  end

  test 'cant exchange award multiple times' do
    post "/awards/#{@award.award_auth_token}/exchange?user_auth_token=#{@user.user_auth_token}",
         headers: authorization_header(@password, @user.username)
    assert_response :ok
    @user.reload
    @user.update!(coins: @award.price)
    post "/awards/#{@award.award_auth_token}/exchange?user_auth_token=#{@user.user_auth_token}",
         headers: authorization_header(@password, @user.username)
    assert_response :bad_request
    body = JSON.parse(response.body)
    assert_equal'Validation failed: Award has already been taken', body['message']
  end

  test 'get all exchanged awards' do
    post "/awards/#{@award.award_auth_token}/exchange",
         headers: authorization_header(@password, @user.username)
    assert_response :ok
    get "/users/#{@user.user_auth_token}/exchanged_awards",
         headers: authorization_header(@password, @user.username)
    assert_response :ok
    body = JSON.parse(response.body)
    e_token = @user.exchanges.first.exchange_auth_token
    assert_equal false, body[0]['used']
    assert_equal @award.award_auth_token, body[0]['award_auth_token']
    assert_equal e_token, body[0]['exchange_auth_token']
  end

  test 'user not found' do
    post "/awards/#{@award.award_auth_token}/exchange?user_auth_token=fake",
         headers: authorization_header(@password, @user.username)
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal'User not found', body['message']
  end

  test 'award not found' do
    post "/awards/fakeAward/exchange?user_auth_token=#{@user.user_auth_token}",
         headers: authorization_header(@password, @user.username)
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal"Award not found", body['message']
  end
end
