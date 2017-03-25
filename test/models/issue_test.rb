require 'test_helper'

class IssueTest < ActiveSupport::TestCase
  def setup
    @user = users(:Lorem)
    @issue = @user.issues.build(title: 'sample issue', latitude: 76.4,
                                longitude: 38.2, category: 'arbolada',
                                picture: 'path', description: 'desc',
                                risk: true, resolved_votes: 564,
                                confirm_votes: 23, reports: 23)
  end

  test 'should be valid' do
    assert @issue.valid?
  end

  test 'title should be present' do
    @issue.title = '     '
    assert_not @issue.valid?
  end

  test 'latitude should be present' do
    @issue.latitude = '     '
    assert_not @issue.valid?
  end

  test 'longitude should be present' do
    @issue.longitude = '     '
    assert_not @issue.valid?
  end

  test 'category should be present' do
    @issue.category = '     '
    assert_not @issue.valid?
  end

  test 'picture should be present' do
    @issue.picture = '     '
    assert_not @issue.valid?
  end

  test 'description should be present' do
    @issue.description = '     '
    assert_not @issue.valid?
  end

  test 'risk should be present' do
    @issue.risk = nil
    assert_not @issue.valid?
  end

  test 'resolved_votes should be present' do
    @issue.resolved_votes = nil
    assert_not @issue.valid?
  end

  test 'confirm_votes should be present' do
    @issue.confirm_votes = nil
    assert_not @issue.valid?
  end

  test 'reports should be present' do
    @issue.reports = nil
    assert_not @issue.valid?
  end

  test 'userid should be present' do
    @issue.user_id = nil
    assert_not @issue.valid?
  end
end
