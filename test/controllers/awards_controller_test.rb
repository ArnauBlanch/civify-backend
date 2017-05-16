require 'test_helper'
require 'rack/test'
require 'base64'

class AwardsControllerTest < ActionDispatch::IntegrationTest

  def setup
    setup_user
    setup_award
  end

  # test 'get all awards request' do
  #   get '/awards', headers: authorization_header(@password, @user.username)
  #   assert_response :ok
  #   assert_equal response.body, Award.all.to_json
  # end

  test 'get all commerce offered awards request' do
    get "/users/#{@user.user_auth_token}/offered_awards",
        headers: authorization_header(@password, @user.username)
    assert_response :ok
    assert_equal response.body, @user.offered_awards.to_json
  end

  test 'create commerce offered award valid request' do
    create_award_post_method
    assert_response :created
    award = Award.find_by(title: 'sample award')
    assert_not_nil award
  end

  test 'create commerce offered award invalid request' do
    post "/users/#{@user.user_auth_token}/offered_awards", params: {
        description: 'desc', picture: sample_image_hash,
        price: 564
    }, headers: authorization_header(@password, @user.username)
    assert_response :bad_request
    body = JSON.parse(response.body)
    assert_equal "Validation failed: Title can't be blank", body['message']
  end


  test 'get award' do
    get "/awards/#{@award.award_auth_token}",
        headers: authorization_header(@password, @user.username)
    assert_response :ok
    assert_equal response.body, @award.to_json
  end

  test 'destroy award valid request' do
    delete "/awards/#{@award.award_auth_token}",
           headers: authorization_header(@password, @user.username)
    assert_response :no_content
    assert_nil Award.find_by(award_auth_token: @award.award_auth_token)
  end

  test 'destroy award invalid request' do
    delete '/awards/123',
           headers: authorization_header(@password, @user.username)
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal "Award not found", body['message']
  end

  test 'update award valid request' do
    patch "/awards/#{@award.award_auth_token}", params: {
        description: 'new desc'
    }, headers: authorization_header(@password, @user.username)
    assert_response :ok
    @award.reload
    assert_equal @award.description, 'new desc'
  end

  test 'update award valid request but ignored' do
    patch "/awards/#{@award.award_auth_token}", params: {
        title: 'title updated',
        titlefake: 'no'
    }, headers: authorization_header(@password, @user.username)
    assert_response :ok
    @award.reload
    assert_equal @award.title, "title updated"
  end

  test 'create commerce offered award image bad format' do
    post "/users/#{@user.user_auth_token}/offered_awards", params: {
        description: 'desc', picture: 'nil',
        price: 564
    }, headers: authorization_header(@password, @user.username)
    assert_response :bad_request
    body = JSON.parse(response.body)
    assert_equal 'Image bad format', body['message']
  end

  def create_award_post_method
    post "/users/#{@user.user_auth_token}/offered_awards", params: {
        title: 'sample award',
        description: 'desc', picture: sample_image_hash,
        price: 564
    }, headers: authorization_header(@password, @user.username)
  end
end
