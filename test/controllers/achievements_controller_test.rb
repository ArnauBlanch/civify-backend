require 'test_helper'

class AchievementsControllerTest < ActionDispatch::IntegrationTest
  def setup
    setup_user(kind: :admin)
  end

  def create_achievement
    post '/achievements', headers: authorization_header(@password, @user.username), params: {
      title: 'Title', description: 'Description',
      number: 5, kind: :issue, coins: 10, xp: 100
    }, as: :json
  end

  test 'create achievement' do
    create_achievement
    assert_response :created
    assert_not_nil Achievement.find_by(number: 5, kind: :issue)
  end

  test 'Achievements are created only by admins' do
    @user.update kind: :normal
    create_achievement
    assert_response :unauthorized
    assert_not Achievement.find_by(number: 5, kind: :issue)
  end
end
