require 'test_helper'

class EventTest < ActiveSupport::TestCase
  def setup
    setup_event
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



end
