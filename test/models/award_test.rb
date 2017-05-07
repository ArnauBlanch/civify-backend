require 'test_helper'

class AwardTest < ActiveSupport::TestCase
  def setup
    setup_user
    setup_award
  end

  test 'should be valid' do
    assert @award.valid?
  end

  test 'title should be present' do
    @award.title = '     '
    assert_not @award.valid?
  end

  test 'picture should be present' do
    @award.picture = nil
    assert_not @award.valid?
  end

  test 'description should be present' do
    @award.description = '     '
    assert_not @award.valid?
  end

  test 'price should be present' do
    @award.price = nil
    assert_not @award.valid?
  end

  test 'offered_by should be present' do
    @award.offered_by = nil
    assert_not @award.valid?
  end

  test 'award is offered by the user' do
    assert_equal @user.to_json, @award.commerce_offering.to_json
  end
end
