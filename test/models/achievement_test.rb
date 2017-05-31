require 'test_helper'

class AchievementTest < ActiveSupport::TestCase
  def setup
    setup_achievement
  end

  test 'achievement should be valid' do
    assert @achievement.valid?
  end

  test 'title should be present' do
    @achievement.title = ''
    assert_not @achievement.valid?
  end

  test 'description should be present' do
    @achievement.description = ''
    assert_not @achievement.valid?
  end

  test 'number should be present' do
    @achievement.number = nil
    assert_not @achievement.valid?
  end

  test 'kind should be present' do
    @achievement.kind = nil
    assert_not @achievement.valid?
  end

  test 'coins should be present' do
    @achievement.coins = nil
    assert_not @achievement.valid?
  end

  test 'xp should be present' do
    @achievement.xp = nil
    assert_not @achievement.valid?
  end

  test 'number - kind uniqueness' do
    aux = @achievement.dup
    aux.achievement_token = 'aa'
    aux.save
    assert_not aux.valid?
    aux.number = @achievement.number + 1
    aux.save
    assert aux.valid?
    aux.number = @achievement.number
    aux.kind = :reward
    aux.save
    assert aux.valid?
  end

  test 'token' do
    assert_not @achievement.achievement_token.nil?
  end
end
