require 'test_helper'

class EventTest < ActiveSupport::TestCase
  def setup
    setup_event(enabled: true)
  end

  test 'should be valid' do
    assert @event.valid?
  end

  test 'title present' do
    @event.title = ''
    assert_not @event.valid?
  end

  test 'description present' do
    @event.description = ''
    assert_not @event.valid?
  end

  test 'number present' do
    @event.number = ''
    assert_not @event.valid?
  end

  test 'coins present' do
    @event.coins = ''
    assert_not @event.valid?
  end

  test 'xp present' do
    @event.xp = ''
    assert_not @event.valid?
  end

  test 'kind present' do
    @event.kind = ''
    assert_not @event.valid?
  end

  test 'kind on enum' do
    # @event.kind = 'instant error (?)'
    # assert_not @event.valid?
    @event.kind = 'issue'
    assert @event.valid?
  end

  test 'start date present' do
    @event.start_date = ''
    assert_not @event.valid?
  end

  test 'end date present' do
    @event.end_date = ''
    assert_not @event.valid?
  end

  test 'end date must be after start date' do
    @event.start_date = '2017-05-1'
    @event.end_date = '2016-05-1'
    assert_not @event.valid?
  end

  test 'number - kind uniqueness' do
    aux = dup_with_badge(@event)
    aux.event_token = 'aa'
    assert_not aux.save
    aux.number = @event.number + 1
    assert aux.save
    aux.number = @event.number
    aux.kind = :reward
    assert aux.save
  end

  test 'token' do
    assert_not @event.event_token.nil?
  end

  test 'enabled scope' do
    previous = @event
    setup_event(enabled: false, number: 1)
    assert_not @event.enabled?
    assert_not @event.enabled == previous.enabled
    enableds = Event.where(enabled: true)
    assert_equal enableds, Event.enabled
    assert_equal enableds, Event.enabled(true)
    assert_equal enableds, Event.enabled(nil)
    assert_equal Event.where(enabled: false), Event.enabled(false)
  end

end
