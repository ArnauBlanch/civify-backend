require 'test_helper'

class EventsControllerTest < ActionDispatch::IntegrationTest
  def setup
    setup_user(kind: :admin)
    setup_event
  end

  def post_event
    post '/events', params: {
        title: 'sample event', description: 'desc',
        image: sample_image_hash, start_date: '10-5-17 16:00:00',
        end_date: '11-5-17 16:00:00', number: 288, coins: 288,
        xp: 288, kind: :issue
    }, headers: authorization_header(@password, @user.username)
  end

  def get_one_event(token)
    get "/events/#{token}", headers: authorization_header(@password, @user.username)
  end

  test 'create events' do
    post_event
    assert_response :created
    assert_not_nil Event.find_by(number: 288, kind: :issue)
  end

  test 'events are created only by admins' do
    @user.update kind: :normal
    post_event
    assert_response :unauthorized
    assert_not Event.find_by(number: 288, kind: :issue)
  end

  test 'create event invalid request' do
    post '/events', params: {
        title: 'sample event', description: 'desc',
        image: sample_image_hash, start_date: '2017-5-17 16:00:00',
        end_date: '2017-5-17 15:00:00', number: 288, coins: 288,
        xp: 288, kind: :issue
    }, headers: authorization_header(@password, @user.username)
    assert_response :bad_request
  end

  test 'get enabled events' do
    setup_event(enabled: "false", number: 5)
    get "/events?enabled=true", headers: authorization_header(@password, @user.username)
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal Event.all.where(enabled: true).to_json, response.body
    assert_not Event.find_by_number(5).enabled
  end

  test 'get disabled events' do
    setup_event(enabled: "false", number: 5)
    get "/events?enabled=false", headers: authorization_header(@password, @user.username)
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal Event.all.where(enabled: false).to_json, response.body
    assert_not Event.find_by_number(5).enabled
    assert_equal false, body[0]['enabled']

  end

  test 'get event' do
    get_one_event @event.event_token
    assert_response :ok
    assert_equal Event.find_by_number(288).to_json, response.body
  end

  test 'get not existing event' do
    get_one_event 1234
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal 'Event does not exists', body['message']
  end

  test 'get event progress when normal or admin user and event active (between end,start date) and enabled' do
    e1 = setup_event(enabled: "false", number: 289, start_date: Date.yesterday, end_date: Date.tomorrow)
    e2 = setup_event(enabled: "true", number: 290, start_date: Date.yesterday, end_date: Date.tomorrow)
    e3 = setup_event(enabled: "true", number: 291, start_date: Date.yesterday, end_date: Date.yesterday)
    get_one_event e1.event_token
    assert_response :ok
    body = JSON.parse(response.body)
    assert_nil body['progress']

    get_one_event e2.event_token
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal 0, body['progress']

    get_one_event e3.event_token
    assert_response :ok
    body = JSON.parse(response.body)
    assert_nil body['progress']
  end

end
