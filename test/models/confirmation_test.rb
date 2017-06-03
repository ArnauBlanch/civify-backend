require 'test_helper'

class ConfirmationTest < ActiveSupport::TestCase
  def setup
    setup_user
    user1 = @user
    setup_user username: '2'
    @user2 = user1
    setup_issue
    @another_issue = @user2.issues.create!(title: 'anotherissue',
                                                 latitude: 76.4,
                                                 longitude: 38.2,
                                                 category: 'arbolada',
                                                 description: 'desc',
                                                 picture: sample_file,
                                                 risk: true)
  end

  test 'no automatic confirmation association when new user issue created' do
    assert @issue.confirmations.empty?
    assert @another_issue.confirmations.empty?
    assert @user.confirmations.empty?
    assert @user2.confirmations.empty?
  end

  test 'confirmation is valid' do
    assert Confirmation.new(user: @user, issue: @issue).valid?
  end

  test 'confirmation is unique' do
    Confirmation.create!(user: @user, issue: @issue)
    assert_not Confirmation.new(user: @user, issue: @issue).valid?
  end

  test 'each user has its created issues' do
    Confirmation.create!(user: @user, issue: @another_issue)
    assert_nil @user.issues.find_by(title: 'anotherissue')
    assert_equal @issue, @user.issues.find_by(title: 'issue')
  end

  test 'confirmations are created' do
    Confirmation.create!(user: @user, issue: @issue)
    assert_equal @user.confirmations.first,
                 Confirmation.find_by(user_id: @user.id)
  end

  test 'created issue is not confirmed issue' do
    @user.confirmations.create!(issue: @another_issue)
    assert_equal @another_issue,
                 @user.confirmed_issues.find_by(title: 'anotherissue')
    assert_not_equal @issue, @user.confirmed_issues.find_by(title: 'issue')
  end
end

