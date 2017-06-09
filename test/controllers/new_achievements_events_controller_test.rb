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
    post_event
    get '/new_achievements_events', headers: authorization_header(@password, @user.username)
    assert_response :ok
    assert_response_body [], :achievements
    assert_response_body [], :events
  end

  test 'request with new achievements' do
    post_achievement
    complete_achievement
    get '/new_achievements_events', headers: authorization_header(@password, @user.username)
    assert_response :ok
    assert_response_body [@achievement], :achievements
    assert_response_body [], :events
  end

  test 'request with new events' do
    post_event
    complete_event
    get '/new_achievements_events', headers: authorization_header(@password, @user.username)
    assert_response :ok
    assert_response_body [], :achievements
    assert_response_body [@event], :events
  end

  test 'request with new achievements and events' do
    post_achievement
    post_event
    complete_achievement
    complete_event
    get '/new_achievements_events', headers: authorization_header(@password, @user.username)
    assert_response :ok
    assert_response_body [@achievement], :achievements
    assert_response_body [@event], :events
  end

  def complete_achievement
    @achievement = @user.achievement_progresses.first
    @achievement.update(completed: true)
    set_current_user(Achievement)
  end

  def complete_event
    @event = @user.event_progresses.first
    @event.update(completed: true)
    set_current_user(Event)
  end

end
