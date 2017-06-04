require 'test_helper'

class ClaimControllerTest < ActionDispatch::IntegrationTest
  def setup
    setup_user(kind: :normal)
  end

  test 'achievement does not exist' do
    post '/achievements/111/claim',
         headers: authorization_header(@password, @user.username)
    assert_response :not_found
    assert_response_body_message 'Achievement does not exist'
  end

  test 'achievement claimed successfully' do
    setup_user(kind: :admin, username: 'admin-user')
    create_achievement
    a = Achievement.find_by(number: 5, kind: 'issue')
    user = User.find_by(kind: :normal)
    setup_reward user
    user.achievement_progresses
        .find_by(achievement_id: a.id)
        .update(completed: true, claimed: false)
    post "/achievements/#{a.achievement_token}/claim",
         headers: authorization_header(@password, user.username)
    assert_response :ok
    assert_reward a.coins, a.xp, user
  end

  test 'achievement already claimed' do
    setup_user(kind: :admin, username: 'admin-user')
    setup_reward
    create_achievement
    a = Achievement.find_by(number: 5, kind: 'issue')
    user = User.find_by(kind: :normal)
    user.achievement_progresses
        .find_by(achievement_id: a.id)
        .update(completed: true, claimed: true)
    post "/achievements/#{a.achievement_token}/claim",
         headers: authorization_header(@password, user.username)
    assert_response :bad_request
    assert_response_body_message 'You have already claimed this achievement'
    assert_reward_not_given
  end

  test 'achievement not completed' do
    setup_user(kind: :admin, username: 'admin-user')
    setup_reward
    create_achievement
    a = Achievement.find_by(number: 5, kind: 'issue')
    user = User.find_by(kind: :normal)
    user.achievement_progresses
        .find_by(achievement_id: a.id)
        .update(completed: false, claimed: false)
    post "/achievements/#{a.achievement_token}/claim",
         headers: authorization_header(@password, user.username)
    assert_response :bad_request
    assert_response_body_message 'You haven\'t completed this achievement yet'
    assert_reward_not_given
  end

  private

  def create_achievement
    post '/achievements', headers: authorization_header(@password, @user.username), params: {
      title: 'Title', description: 'Description',
      number: 5, kind: :issue, coins: 10, xp: 100
    }, as: :json
    assert_response :created
  end

end
