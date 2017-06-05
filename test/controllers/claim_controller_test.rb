require 'test_helper'

class ClaimControllerTest < ActionDispatch::IntegrationTest
  def setup
    setup_user(kind: :normal)
    setup_event(number: 5)
    setup_achievement(number: 5)
  end

  test 'achievement does not exist' do
    post '/achievements/111/claim',
         headers: authorization_header(@password, @user.username)
    assert_response :not_found
    assert_response_body_message 'Achievement does not exist'
  end

  test 'achievement claimed successfully' do
    setup_user(kind: :admin, username: 'admin-user')
    post_achievement
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
    post_achievement
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
    post_achievement
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

  test 'event does not exist' do
    post '/events/111/claim',
         headers: authorization_header(@password, @user.username)
    assert_response :not_found
    assert_response_body_message 'Event does not exist'
  end

  test 'event claimed successfully' do
    setup_user(kind: :admin, username: 'admin-user')
    post_event
    e = Event.find_by(number: 5, kind: 'issue')
    user = User.find_by(kind: :normal)
    setup_reward user
    user.event_progresses
        .find_by(event_id: e.id)
        .update(completed: true, claimed: false)
    post "/events/#{e.event_token}/claim",
         headers: authorization_header(@password, user.username)
    assert_response :ok
    assert_reward e.coins, e.xp, user
  end

  test 'event already claimed' do
    setup_user(kind: :admin, username: 'admin-user')
    setup_reward
    post_event
    e = Event.find_by(number: 5, kind: 'issue')
    user = User.find_by(kind: :normal)
    user.event_progresses
        .find_by(event_id: e.id)
        .update(completed: true, claimed: true)
    post "/events/#{e.event_token}/claim",
         headers: authorization_header(@password, user.username)
    assert_response :bad_request
    assert_response_body_message 'You have already claimed this event'
    assert_reward_not_given
  end

  test 'event not completed' do
    setup_user(kind: :admin, username: 'admin-user')
    setup_reward
    post_event
    e = Event.find_by(number: 5, kind: 'issue')
    user = User.find_by(kind: :normal)
    user.event_progresses
        .find_by(event_id: e.id)
        .update(completed: false, claimed: false)
    post "/events/#{e.event_token}/claim",
         headers: authorization_header(@password, user.username)
    assert_response :bad_request
    assert_response_body_message 'You haven\'t completed this event yet'
    assert_reward_not_given
  end
end
