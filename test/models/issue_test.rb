require 'test_helper'

class IssueTest < ActiveSupport::TestCase
  def setup
    setup_user
    setup_issue
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
    @issue.picture = nil
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

  test 'userid should be present' do
    @issue.user_id = nil
    assert_not @issue.valid?
  end
end
