require 'test_helper'

# Tests the User model
class UserTest < ActiveSupport::TestCase
  def setup
    setup_user
  end

  test 'user should be valid' do
    assert @user.valid?
  end

  test 'username should be present' do
    @user.username = ''
    assert_not @user.valid?
  end

  test 'email should be present' do
    @user.email = ''
    assert_not @user.valid?
  end

  test 'first_name should be present' do
    @user.first_name = ''
    assert_not @user.valid?
  end

  test 'last_name should be present' do
    @user.last_name = ''
    assert_not @user.valid?
  end

  test 'username should be unique' do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test 'email should be unique' do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test 'username shouldn\'t be case sensitive (case 1)' do
    duplicate_user = @user.dup
    duplicate_user.username = duplicate_user.username.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test 'username shouldn\'t be case sensitive (case 2)' do
    duplicate_user = @user.dup
    @user.username = @user.username.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test 'email shouldn\'t be case sensitive (case 1)' do
    duplicate_user = @user.dup
    duplicate_user.email = duplicate_user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test 'email shouldn\'t be case sensitive (case 2)' do
    duplicate_user = @user.dup
    @user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test 'user token is not null' do
    @user.save
    assert_not_nil @user.user_auth_token
  end

  test 'user can have issues' do
    setup_issue
    assert_not_nil @issue
    assert_equal @issue.to_json, @user.issues.first.to_json
  end

  test 'user can have awards' do
    setup_award
    assert_not_nil @award
    assert_equal @award.to_json, @user.offered_awards.first.to_json
  end

  test 'user by default is of kind normal' do
    assert @user.normal?
  end

  test 'user experience by default is 0' do
    assert @user.xp.zero?
  end

  test 'user level by default is 1' do
    assert @user.level == 1
  end

  test 'user level cannot be higher than max level' do
    @user.update(xp: User.get_min_xp_from_lv(User::MAX_LEVEL + 1))
    assert @user.level == User::MAX_LEVEL
  end

  test 'user current experience is 0 if max level achieved' do
    @user.update(xp: User.get_min_xp_from_lv(User::MAX_LEVEL) + 1)
    assert @user.current_xp.zero?
  end

  private

  def setup_issue
    @issue = @user.issues.new(title: 'sample issue', latitude: 76.4,
                              longitude: 38.2, category: 'arbolada',
                              description: 'desc',
                              risk: true, resolved_votes: 564)
    @issue.picture = sample_file
  end

  def sample_file(filename = 'image.gif')
    File.new("test/fixtures/#{filename}")
  end
end
