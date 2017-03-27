require 'test_helper'
require "rack/test"

class IssuesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = User.create(name: 'user')
    @picture = sample_file
    @issue = @user.issues.create!(title: 'issue', latitude: 76.4,
                                  longitude: 38.2, category: 'arbolada',
                                  description: 'desc', picture: @picture,
                                  risk: true, resolved_votes: 564,
                                  confirm_votes: 23, reports: 23)
  end

  def teardown
    Issue.delete_all
    User.delete_all
  end

  test 'get all user issues request' do
    # debugger
    get "/users/#{@user.user_auth_token}/issues"
    assert_response :ok
    assert_equal response.body, @user.issues.to_json
  end

  test 'get user issue by token request' do
    get "/users/#{@user.user_auth_token}/issues/#{@issue.issue_auth_token}"
    assert_response :ok
    assert_equal response.body, @issue.to_json
  end

  test 'create user issue valid request' do
    post "/users/#{@user.user_auth_token}/issues", params: {
          title: 'sample issue', latitude: 76.4,
          longitude: 38.2, category: 'arbolada',
          description: 'desc', picture: sample_image_hash,
          risk: true, resolved_votes: 564,
          confirm_votes: 23, reports: 23
    }
    assert_response :created
    assert_not_nil Issue.find_by(title: 'sample issue')
    assert_equal response.body, Issue.find_by(title: 'sample issue').to_json
  end

  test 'create user issue invalid request' do
    post "/users/#{@user.user_auth_token}/issues", params: {
        latitude: 76.4,
        longitude: 38.2, category: 'arbolada',
        description: 'desc', picture: sample_image_hash,
        risk: true, resolved_votes: 564,
        confirm_votes: 23, reports: 23
    }
    assert_response :bad_request
    body = JSON.parse(response.body)
    assert_equal "Validation failed: Title can't be blank", body['message']
  end

  test 'destroy user issue valid request' do
    delete "/users/#{@user.user_auth_token}/issues/#{@issue.issue_auth_token}"
    assert_response :no_content
    assert_nil Issue.find_by(issue_auth_token: @issue.issue_auth_token)
  end

  test 'destroy user issue invalid request' do
    delete "/users/#{@user.user_auth_token}/issues/123"
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal "Doesn't exists record", body['message']
  end

  test 'update user issue valid request' do
    patch "/users/#{@user.user_auth_token}/issues/#{@issue.issue_auth_token}", params: {
        category: "nuclear"
    }
    assert_response :ok
    @issue.reload
    assert_equal @issue.category, "nuclear"
    # assert_equal response.body, @issue.to_json check json order
  end

  test 'update user issue valid request but ignored values' do
    patch "/users/#{@user.user_auth_token}/issues/#{@issue.issue_auth_token}", params: {
        title: "title updated",
        titlefake: "no"
    }
    assert_response :ok
    @issue.reload
    assert_equal @issue.title, "title updated"
    # assert_equal response.body, @issue.to_json check json order
  end

  test 'get issue' do
    get "/issues/#{@issue.issue_auth_token}"
    assert_response :ok
    assert_equal response.body, @issue.to_json
  end

  test 'destroy issue valid request' do
    delete "/issues/#{@issue.issue_auth_token}"
    assert_response :no_content
    assert_nil Issue.find_by(issue_auth_token: @issue.issue_auth_token)
  end

  test 'destroy issue invalid request' do
    delete "/issues/123"
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal "Doesn't exists record", body['message']
  end
  
  test 'update issue valid request' do
    patch "/issues/#{@issue.issue_auth_token}", params: {
        category: "nuclear"
    }
    assert_response :ok
    @issue.reload
    assert_equal @issue.category, "nuclear"
  end

  test 'update issue valid request but ignored' do
    patch "/issues/#{@issue.issue_auth_token}", params: {
        title: "title updated",
        titlefake: "no"
    }
    assert_response :ok
    @issue.reload
    assert_equal @issue.title, "title updated"
  end

  test 'create usser isue image bad format' do
    post "/users/#{@user.user_auth_token}/issues", params: {
        latitude: 76.4,
        longitude: 38.2, category: 'arbolada',
        description: 'desc', picture: "nil",
        risk: true, resolved_votes: 564,
        confirm_votes: 23, reports: 23
    }
    assert_response :bad_request
    body = JSON.parse(response.body)
    assert_equal "Image bad format", body['error']
  end

  def sample_file(filename = "image.gif")
    File.new("test/fixtures/#{filename}")
  end

  def sample_image_hash
    content = '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'
    { filename: 'image.gif', content: content, content_type: 'image/gif' }
  end

end
