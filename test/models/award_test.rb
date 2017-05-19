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

  test 'award json contains number of times exchanged' do
    @user.exchanged_awards << @award
    @exchange = @user.exchanges.find_by!(award_id: @award.id)
    @exchange.used = true
    @exchange.save!
    award_hash = JSON.parse @award.to_json
    assert_equal 1, award_hash['num_exchanges']
    assert_equal 1, award_hash['num_usages']
  end
end
