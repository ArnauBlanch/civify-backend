require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  def setup
    setup_user
    setup_issue
    @second_user = User.create!(username: 'test2',
                                email: 'test2@test.com',
                                first_name: 'test', last_name: 'test',
                                password: @password,
                                password_confirmation: '1234')
    @another_issue = @second_user.issues.create!(title: 'anotherissue',
                                                 latitude: 76.4,
                                                 longitude: 38.2,
                                                 category: 'arbolada',
                                                 description: 'desc',
                                                 picture: sample_file,
                                                 risk: false)
  end

  test 'no automatic report association when new user issue created' do
    assert @issue.reports.empty?
    assert @another_issue.reports.empty?
    assert @user.reports.empty?
    assert @second_user.reports.empty?
  end

  test 'report is valid' do
    assert Report.new(user: @user, issue: @issue).valid?
  end

  test 'report is unique' do
    Report.create!(user: @user, issue: @issue)
    assert_not Report.new(user: @user, issue: @issue).valid?
  end

  test 'each user has its created issues' do
    Report.create!(user: @user, issue: @another_issue)
    assert_nil @user.issues.find_by(title: 'anotherissue')
    assert_equal @issue, @user.issues.find_by(title: 'issue')
  end

  test 'reports are created' do
    Report.create!(user: @user, issue: @issue)
    assert_equal @user.reports.first,
                 Report.find_by(user_id: @user.id)
  end

  test 'created issue is not reported issue' do
    @user.reports.create!(issue: @another_issue)
    assert_equal @another_issue,
                 @user.reported_issues.find_by(title: 'anotherissue')
    assert_not_equal @issue, @user.reported_issues.find_by(title: 'issue')
  end
end
