require 'test_helper'

class EventsControllerTest < ActionDispatch::IntegrationTest
  def setup
    setup_user({ kind: :admin})
  end

  def create_event_post
    post "/events", params: {
        title: 'sample event', description: 'desc',
        image: sample_image_hash, start_date: '10-5-17 16:00:00',
        end_date: '11-5-17 16:00:00', number: 288, coins: 288,
        xp: 288, kind: :issue
    }, headers: authorization_header(@password, @user.username)
  end

  test 'create events' do
    create_event_post
    assert_response :created
    assert_not_nil Event.find_by(number: 288, kind: :issue)
  end

  test 'Events are created only by admins' do
    @user.update kind: :normal
    create_event_post
    assert_response :unauthorized
    assert_not Event.find_by(number: 288, kind: :issue)
  end


end
