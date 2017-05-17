require 'test_helper'

class ExchangesControllerTest < ActionDispatch::IntegrationTest
  def setup
    setup_user
    setup_award
  end

  test 'exchange award by auth user' do
    post "/awards/#{@award.award_auth_token}/exchange",
         headers: authorization_header(@password, @user.username)
    assert_response :ok
    assert @award.users_exchanging.exists?(@user.id)
    assert @user.exchanged_awards.exists?(@award.id)
  end

  test 'cant exchange award multiple times' do
    post "/awards/#{@award.award_auth_token}/exchange",
         headers: authorization_header(@password, @user.username)
    assert_response :ok
    post "/awards/#{@award.award_auth_token}/exchange",
         headers: authorization_header(@password, @user.username)
    assert_response :bad_request
    body = JSON.parse(response.body)
    assert_equal'Validation failed: Award has already been taken', body['message']
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
