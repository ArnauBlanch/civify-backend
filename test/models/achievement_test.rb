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
    aux = dup_with_badge(@achievement)
    aux.achievement_token = 'aa'
    assert_not aux.save
    aux.number = @achievement.number + 1
    assert aux.save
    aux.number = @achievement.number
    aux.kind = :reward
    assert aux.save
  end

  test 'token' do
    assert_not @achievement.achievement_token.nil?
  end

  test 'enabled scope' do
    previous = @achievement
    setup_achievement(enabled: false, number: 1)
    assert_not @achievement.enabled?
    assert_not @achievement.enabled == previous.enabled
    enableds = Achievement.where(enabled: true)
    assert_equal enableds, Achievement.enabled
    assert_equal enableds, Achievement.enabled(true)
    assert_equal enableds, Achievement.enabled(nil)
    assert_equal Achievement.where(enabled: false), Achievement.enabled(false)
  end

end
