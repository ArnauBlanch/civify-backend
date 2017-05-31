require 'test_helper'

class AchievementsControllerTest < ActionDispatch::IntegrationTest
  def setup
    setup_user
  end

  test 'create achievement' do
    post '/achievements', headers: authorization_header(@password,
                                                        @user.username),
                          params: {
                            title: 'Title', description: 'Description',
                            number: 5, kind: :issue, coins: 10, xp: 100
                          }, as: :json
    assert_response :created
    assert_not_nil Achievement.find_by(number: 5, kind: :issue)
  end
end
