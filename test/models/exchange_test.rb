require 'test_helper'

class ExchangeTest < ActiveSupport::TestCase

  def setup
    setup_user
    setup_award
    @user.exchanged_awards << @award
    @exchange = @user.exchanges.find_by!(award_id: @award.id)
  end

  test 'should be valid' do
    assert @exchange.valid?
  end

  test 'exchange is unique' do
    assert_not Exchange.new(user: @user, award: @award).valid?
  end

  test 'belongs to their user and award' do
    assert_equal  @award.id,@exchange.award_id
    assert_equal @user.id, @exchange.user_id
  end

  test 'as_json override is correct' do
    hash = JSON.parse @exchange.to_json
    exchange_original_hash = @exchange.attributes
    exchange_original_hash.delete "updated_at"
    exchange_original_hash.delete "created_at"
    exchange_original_hash.delete "id"
    exchange_original_hash.delete "user_id"
    exchange_original_hash.delete "award_id"
    exchange_expected_hash = JSON.parse(@award.to_json).merge exchange_original_hash
    assert_equal exchange_expected_hash, hash
  end

end
