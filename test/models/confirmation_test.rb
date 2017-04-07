require 'test_helper'

class ConfirmationTest < ActiveSupport::TestCase
  def setup
    setup_user
    @issue = @user.issues.create!(title: 'issue', latitude: 76.4,
                                  longitude: 38.2, category: 'arbolada',
                                  description: 'desc', picture: sample_file,
                                  risk: true, resolved_votes: 564,
                                  confirm_votes: 23, reports: 23)
    @second_user = User.create!(username: 'test2',
                                       email: 'test2@test.com',
                                       first_name: 'test', last_name: 'test',
                                       password: @password, password_confirmation: '1234')
    @another_issue = @second_user.issues.create!(title: 'anotherissue', latitude: 76.4,
                                                longitude: 38.2, category: 'arbolada',
                                                description: 'desc', picture: sample_file,
                                                risk: true, resolved_votes: 564,
                                                confirm_votes: 23, reports: 23)
  end

  test 'no automatic confirmation association when new user issue created' do
    assert @issue.confirmations.empty?
    assert @another_issue.confirmations.empty?
    assert @user.confirmations.empty?
    assert @second_user.confirmations.empty?
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
    assert_equal @user.confirmations.first, Confirmation.find_by(user_id: @user.id)
  end

  test 'created issues is not confirmed issues' do
    @user.confirmations.create!(issue: @another_issue)
    assert_equal @another_issue, @user.confirmed_issues.find_by(title: 'anotherissue')
    assert_not_equal @issue, @user.confirmed_issues.find_by(title: 'issue')
  end
end

