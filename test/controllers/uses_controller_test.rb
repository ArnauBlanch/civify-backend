require 'test_helper'

class UsesControllerTest < ActionDispatch::IntegrationTest
  def setup
    setup_user
    setup_award
    @user.exchanged_awards << @award
  end

  def get_exchange
    @exchange = @user.exchanges.find_by!(award_id: @award.id)
  end

  test 'use award by auth user valid request' do
    post "/awards/#{@award.award_auth_token}/use",
         headers: authorization_header(@password, @user.username)
    assert_response :ok
    get_exchange
    assert @exchange.used
  end

  test 'award already used' do
    post "/awards/#{@award.award_auth_token}/use",
         headers: authorization_header(@password, @user.username)
    assert_response :ok
    post "/awards/#{@award.award_auth_token}/use",
         headers: authorization_header(@password, @user.username)
    body = JSON.parse(response.body)
    assert_response :bad_request
    assert_equal 'User has already used this award', body['message']
  end

  test 'use a not exchanged award' do
    @user.exchanged_awards.delete(@award)
    post "/awards/#{@award.award_auth_token}/use",
         headers: authorization_header(@password, @user.username)
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal "User doesn't own this award", body['message']
  end

  test 'user not found' do
    post "/awards/#{@award.award_auth_token}/use?user_auth_token=fake",
         headers: authorization_header(@password, @user.username)
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal'User not found', body['message']
  end

  test 'award not found' do
    post "/awards/fakeAward/use?user_auth_token=#{@user.user_auth_token}",
         headers: authorization_header(@password, @user.username)
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal"Award not found", body['message']
  end
end
