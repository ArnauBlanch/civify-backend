require 'test_helper'

class AchievementProgressesTest < ActionDispatch::IntegrationTest
  RESOLVE_IN = 10

  def setup
    setup_users
  end

  test 'create issues achievement' do
    create_achievement @admin1, 'issue', 2
    achievement1 = Achievement.find_by(kind: 'issue', number: 2)
    create_issue @user1
    assert_equal 1, @user1.achievement_progresses.find_by(achievement_id: achievement1.id).progress
    create_issue @user1
    assert_equal 2, @user1.achievement_progresses.find_by(achievement_id: achievement1.id).progress
    assert @user1.achievement_progresses.find_by(achievement_id: achievement1.id).completed
    create_issue @user1
    assert_equal 2, @user1.achievement_progresses.find_by(achievement_id: achievement1.id).progress
    assert @user1.achievement_progresses.find_by(achievement_id: achievement1.id).completed
  end

  test 'confirm and confirm received achievement' do
    create_achievement @admin1, 'confirm', 2
    create_achievement @admin1, 'confirm_received', 2
    achievement1 = Achievement.find_by(kind: 'confirm', number: 2)
    achievement2 = Achievement.find_by(kind: 'confirm_received', number: 2)
    create_issue @user1
    confirm_issue @user2, @user1.issues.first
    assert_equal 1, @user2.achievement_progresses.find_by(achievement_id: achievement1.id).progress
    assert_equal 1, @user1.achievement_progresses.find_by(achievement_id: achievement2.id).progress
    create_issue @user1
    confirm_issue @user2, @user1.issues.second
    assert_equal 2, @user2.achievement_progresses.find_by(achievement_id: achievement1.id).progress
    assert_equal 2, @user1.achievement_progresses.find_by(achievement_id: achievement2.id).progress
    assert @user2.achievement_progresses.find_by(achievement_id: achievement1.id).completed
    assert @user1.achievement_progresses.find_by(achievement_id: achievement2.id).completed
    create_issue @user1
    confirm_issue @user2, @user1.issues.third
    assert_equal 2, @user2.achievement_progresses.find_by(achievement_id: achievement1.id).progress
    assert_equal 2, @user1.achievement_progresses.find_by(achievement_id: achievement2.id).progress
    assert @user2.achievement_progresses.find_by(achievement_id: achievement1.id).completed
    assert @user1.achievement_progresses.find_by(achievement_id: achievement2.id).completed
  end

  test 'resolve and resolve received achievement' do
    create_achievement @admin1, 'resolve', 2
    create_achievement @admin1, 'resolve_received', 2
    achievement1 = Achievement.find_by(kind: 'resolve', number: 2)
    achievement2 = Achievement.find_by(kind: 'resolve_received', number: 2)
    create_issue @user1
    resolve_issue @user2, @user1.issues.first
    assert_equal 1, @user2.achievement_progresses.find_by(achievement_id: achievement1.id).progress
    assert_equal 1, @user1.achievement_progresses.find_by(achievement_id: achievement2.id).progress
    create_issue @user1
    resolve_issue @user2, @user1.issues.second
    assert_equal 2, @user2.achievement_progresses.find_by(achievement_id: achievement1.id).progress
    assert_equal 2, @user1.achievement_progresses.find_by(achievement_id: achievement2.id).progress
    assert @user2.achievement_progresses.find_by(achievement_id: achievement1.id).completed
    assert @user1.achievement_progresses.find_by(achievement_id: achievement2.id).completed
    create_issue @user1
    resolve_issue @user2, @user1.issues.third
    assert_equal 2, @user2.achievement_progresses.find_by(achievement_id: achievement1.id).progress
    assert_equal 2, @user1.achievement_progresses.find_by(achievement_id: achievement2.id).progress
    assert @user2.achievement_progresses.find_by(achievement_id: achievement1.id).completed
    assert @user1.achievement_progresses.find_by(achievement_id: achievement2.id).completed
  end

  test 'exchange rewards and coins spent achievements' do
    create_achievement @admin1, 'reward', 2
    create_achievement @admin1, 'coins_spent', 10
    achievement1 = Achievement.find_by(kind: 'reward', number: 2)
    achievement2 = Achievement.find_by(kind: 'coins_spent', number: 10)
    create_rewards
    @user1.update(coins: 50)
    exchange_reward @user1, @reward1
    assert_equal 1, @user1.achievement_progresses.find_by(achievement_id: achievement1.id).progress
    assert_equal @reward1.price, @user1.achievement_progresses.find_by(achievement_id: achievement2.id).progress
    exchange_reward @user1, @reward2
    assert_equal 2, @user1.achievement_progresses.find_by(achievement_id: achievement1.id).progress
    assert_equal achievement2.number, @user1.achievement_progresses.find_by(achievement_id: achievement2.id).progress
    assert @user1.achievement_progresses.find_by(achievement_id: achievement1.id).completed
    assert @user1.achievement_progresses.find_by(achievement_id: achievement2.id).completed
    exchange_reward @user1, @reward3
    assert_equal 2, @user1.achievement_progresses.find_by(achievement_id: achievement1.id).progress
    assert_equal achievement2.number, @user1.achievement_progresses.find_by(achievement_id: achievement2.id).progress
    assert @user1.achievement_progresses.find_by(achievement_id: achievement1.id).completed
    assert @user1.achievement_progresses.find_by(achievement_id: achievement2.id).completed
  end

  test 'issues resolved achievement' do
    create_achievement @admin1, 'issues_resolved', 1
    achievement1 = Achievement.find_by(kind: 'issues_resolved', number: 1)
    create_issue @user1
    issue = @user1.issues.first
    issue.update(resolved_votes: RESOLVE_IN - 1)
    resolve_issue @user2, issue
    assert issue.resolved
    assert_equal 1, @user1.achievement_progresses.find_by(achievement_id: achievement1.id).progress
    assert @user1.achievement_progresses.find_by(achievement_id: achievement1.id).completed
  end

  test 'level achievement' do
    create_achievement @admin1, 'level', 3
    achievement1 = Achievement.find_by(kind: 'level', number: 3)
    before_level = @user1.level
    i = 0
    while i < 8
      create_issue @user1
      i += 1
    end
    after_level = @user1.level
    assert_equal after_level - before_level,
                 @user1.achievement_progresses.find_by(achievement_id: achievement1.id).progress
    assert @user1.achievement_progresses.find_by(achievement_id: achievement1.id).completed
  end

  private

  def create_issue(user)
    post "/users/#{user.user_auth_token}/issues", params: {
        title: 'sample issue', latitude: 76.4,
        longitude: 38.2, category: 'arbolada',
        description: 'desc', picture: sample_image_hash,
        risk: false
    }, headers: authorization_header(@password, user.username)
    assert_response :created
    user.reload
  end

  def create_achievement(user, kind, number)
    badge_image = sample_image_hash
    post '/achievements', headers: authorization_header(@password, user.username), params: {
        title: 'Title', description: 'Description',
        number: number, kind: kind, coins: 10, xp: 100, badge: {
            title: 'Badge title',
            file_name: badge_image[:file_name],
            content: badge_image[:content],
            content_type: badge_image[:content_type]
        }
    }, as: :json
    assert_response :created
    user.reload
  end

  def create_rewards
    create_reward @business1, 7
    @reward1 = @award
    create_reward @business1, 7
    @reward2 = @award
    create_reward @business1, 7
    @reward3 = @award
  end

  def create_reward(user, price)
    @picture = sample_file
    @award = user.offered_awards.create!(title: 'award', description: 'desc',
                                          picture: @picture, price: price)
    assert @award.valid?
    user.reload
  end

  def confirm_issue(user, issue)
    post "/issues/#{issue.issue_auth_token}/confirm",
         headers: authorization_header(@password, user.username)
    assert_response :ok
    user.reload
    issue.reload
  end

  def resolve_issue(user, issue)
    post "/issues/#{issue.issue_auth_token}/resolve",
         headers: authorization_header(@password, user.username),
         params: { user: user.user_auth_token }, as: :json
    assert_response :ok
    user.reload
    issue.reload
  end

  def exchange_reward(user, reward)
    post "/awards/#{reward.award_auth_token}/exchange",
         headers: authorization_header(@password, user.username)
    assert_response :ok
    user.reload
    reward.reload
  end

  def setup_users
    setup_user(username: 'user1', kind: 'normal')
    @user1 = @user
    setup_user(username: 'user2', kind: 'normal')
    @user2 = @user
    setup_user(username: 'admin1', kind: 'admin')
    @admin1 = @user
    setup_user(username: 'business1', kind: 'business')
    @business1 = @user
    assert_equal 'user1', @user1.username
    assert @user1.valid?
    assert_equal 'user2', @user2.username
    assert @user2.valid?
    assert_equal 'admin1', @admin1.username
    assert @admin1.valid?
    assert_equal 'business1', @business1.username
    assert @business1.valid?
  end
end
