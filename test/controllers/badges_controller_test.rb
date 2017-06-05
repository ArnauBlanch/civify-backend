require 'test_helper'

class BadgesControllerTest < ActionDispatch::IntegrationTest
  def setup
    setup_achievement(number: 2)
    setup_event(number: 2)
    setup_user
  end

  test 'get all user badges' do
    @user.achievements_in_progress << @achievement
    @user.events_in_progress << @event
    ap = @user.achievement_progresses.first
    ep = @user.event_progresses.first
    get "/users/#{@user.user_auth_token}/badges", headers: authorization_header(@password, @user.username)
    assert_response :ok
    assert_response_body [], :achievements
  end
end
