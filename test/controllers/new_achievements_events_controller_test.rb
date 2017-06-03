require 'test_helper'

class NewAchievementsEventsControllerTest < ActionDispatch::IntegrationTest
  def setup
    setup_user(kind: :admin)
  end

  test 'admin user request' do
    get '/new_achievements_events',
        headers: authorization_header(@password,
                                      @user.username)
    assert_response :unauthorized
    body = JSON.parse(response.body)
    assert_equal 'Invalid request for admins and businesses',
                 body['message']
  end

  test 'business user request' do
    @user.update(kind: 'business')
    get '/new_achievements_events',
        headers: authorization_header(@password,
                                      @user.username)
    assert_response :unauthorized
    body = JSON.parse(response.body)
    assert_equal 'Invalid request for admins and businesses',
                 body['message']
  end

  test 'without authorization header request' do
    get '/new_achievements_events'
    assert_response :unauthorized
    body = JSON.parse(response.body)
    assert_equal 'Missing Authorization Token',
                 body['message']
  end

  test 'normal user request without new achievements' do
    setup_user(kind: :normal, username: 'normal')
    setup_user(kind: :admin, username: 'admin2')
    create_achievement
    normal = User.find_by(username: 'normal')
    get '/new_achievements_events',
        headers: authorization_header(@password,
                                      normal.username)
    assert_response :ok
    body = JSON.parse(response.body)
    assert_not body['achievements']
  end

  test 'normal user request with new achievements' do
    setup_user(kind: :normal, username: 'normal')
    setup_user(kind: :admin, username: 'admin2')
    create_achievement
    normal = User.find_by(username: 'normal')
    normal.achievement_progresses.first.update(completed: true)
    get '/new_achievements_events',
        headers: authorization_header(@password,
                                      normal.username)
    assert_response :ok
    body = JSON.parse(response.body)
    assert body['achievements']
  end

  private

  def create_achievement
    post '/achievements', headers: authorization_header(@password, @user.username), params: {
        title: 'Title', description: 'Description',
        number: 5, kind: :issue, coins: 10, xp: 100
    }, as: :json
  end
end
