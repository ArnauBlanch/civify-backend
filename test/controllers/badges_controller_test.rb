require 'test_helper'

class BadgesControllerTest < ActionDispatch::IntegrationTest
  def setup
    setup_achievement(number: 2)
    setup_event(number: 2)
    setup_user
  end

  def claim_achievement
    post "/achievements/#{@achievement.achievement_token}/claim",
         headers: authorization_header(@password, @user.username)
    assert_response :ok
  end

  def claim_event
    post "/events/#{@event.event_token}/claim",
         headers: authorization_header(@password, @user.username)
    assert_response :ok
  end

  def get_badges
    get "/users/#{@user.user_auth_token}/badges", headers: authorization_header(@password, @user.username)
    assert_response :ok
  end

  test 'get all user badges' do
    @user.achievements_in_progress << @achievement
    @user.events_in_progress << @event
    ap = @user.achievement_progresses.first
    ep = @user.event_progresses.first
    ap.update(completed: true)
    ep.update(completed: true)
    claim_achievement
    ap.reload
    assert_response_body @achievement.badge, :badge
    claim_event
    assert_response_body @event.badge, :badge
    get_badges
    assert_response_body [ap.achievement.badge, ep.event.badge]
    assert_response_body ap.updated_at, [0, :obtained_date]
    assert_response_body ep.updated_at, [1, :obtained_date]
    assert_response_body "Achievement", [0, :corresponds_to_type]
    assert_response_body "Event", [1, :corresponds_to_type]
    assert_response_body @achievement.achievement_token, [0, :corresponds_to_token]
    assert_response_body @event.event_token, [1, :corresponds_to_token]
  end
end
