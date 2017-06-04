require 'test_helper'

class AchievementsControllerTest < ActionDispatch::IntegrationTest
  def setup
    setup_user(kind: :admin)
  end

  test 'create achievement' do
    post_achievement
    assert_response :created
    achievement = Achievement.find_by(number: 5, kind: :issue)
    assert_not_nil achievement
    assert_equal achievement.to_json, response.body
    assert 1, @user.achievement_progresses.size
  end

  test 'achievements are created only by admins' do
    @user.update! kind: :normal
    check_post_unauthorized
    @user.update! kind: :business
    check_post_unauthorized
  end

  def check_post_unauthorized
    post_achievement
    assert_response :unauthorized
    assert_not Achievement.find_by(number: 5, kind: :issue)
  end

  test 'get achievements' do
    get '/achievements', headers: authorization_header(@password, @user.username)
    assert_response :ok
    assert_equal Achievement.all.to_json, response.body
  end

  test 'get one achievement' do
    setup_achievement
    get "/achievements/#{@achievement.achievement_token}", headers: authorization_header(@password, @user.username)
    assert_response :ok
    assert_equal @achievement.to_json, response.body
  end

  test 'get achievements unauthorized' do
    get '/achievements'
    assert_response :unauthorized
    assert_response_body_message 'Missing Authorization Token'
  end

  test 'get one achievement unauthorized' do
    setup_achievement
    get "/achievements/#{@achievement.achievement_token}"
    assert_response :unauthorized
    assert_response_body_message 'Missing Authorization Token'
  end

  test 'get one achievement not found' do
    get '/achievements/1', headers: authorization_header(@password, @user.username)
    assert_response :not_found
    assert_response_body_message 'Achievement does not exists'
  end
end
