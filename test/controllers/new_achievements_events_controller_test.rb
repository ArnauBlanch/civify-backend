require 'test_helper'

class NewAchievementsEventsControllerTest < ActionDispatch::IntegrationTest

  def setup
    setup_user(kind: :admin)
  end

  test 'without authorization header request' do
    get '/new_achievements_events'
    assert_response :unauthorized
    assert_response_body_message 'Missing Authorization Token'
  end

  test 'request without new achievements nor events' do
    post_achievement
    get '/new_achievements_events', headers: authorization_header(@password, @user.username)
    assert_response :ok
    assert_response_body false, :achievements
    assert_response_body false, :events
  end

  test 'request with new achievements' do
    post_achievement
    @user.achievement_progresses.first.update(completed: true)
    get '/new_achievements_events', headers: authorization_header(@password, @user.username)
    assert_response :ok
    assert_response_body true, :achievements
  end

  test 'request without new events' do
    post_event
    get '/new_achievements_events', headers: authorization_header(@password, @user.username)
    assert_response :ok
    assert_response_body false, :events
  end

  test 'request with new events' do
    post_event
    @user.event_progresses.first.update(completed: true)
    get '/new_achievements_events', headers: authorization_header(@password, @user.username)
    assert_response :ok
    assert_response_body true, :events
  end

  test 'request with new achievements and events' do
    post_achievement
    post_event
    @user.achievement_progresses.first.update(completed: true)
    @user.event_progresses.first.update(completed: true)
    get '/new_achievements_events', headers: authorization_header(@password, @user.username)
    assert_response :ok
    assert_response_body true, :achievements
    assert_response_body true, :events
  end

end
