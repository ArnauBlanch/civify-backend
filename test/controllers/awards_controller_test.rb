require 'test_helper'
require 'rack/test'
require 'base64'

class AwardsControllerTest < ActionDispatch::IntegrationTest

  def setup
    setup_user(kind: :business)
    setup_award
  end

  test 'get all awards request' do
    get '/awards', headers: authorization_header(@password, @user.username)
    assert_response :ok
    assert_equal Award.all.to_json, response.body
  end

  test 'get all commerce offered awards request' do
    get "/users/#{@user.user_auth_token}/offered_awards",
        headers: authorization_header(@password, @user.username)
    assert_response :ok
    assert_equal @user.offered_awards.to_json, response.body
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
    assert_equal "Title can't be blank", body['message']
  end

  test 'create commerce offered award invalid request no image' do
    post "/users/#{@user.user_auth_token}/offered_awards", params: {
      description: 'desc',
      price: 564, title: 'turtle'
    }, headers: authorization_header(@password, @user.username)
    assert_response :bad_request
    body = JSON.parse(response.body)
    assert_equal "Picture can't be blank", body['message']
  end


  test 'get award' do
    get "/awards/#{@award.award_auth_token}",
        headers: authorization_header(@password, @user.username)
    assert_response :ok
    assert_equal @award.to_json, response.body
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
    assert_equal 'Award not found', body['message']
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
    assert_equal @award.title, 'title updated'
  end

  test 'create commerce offered award image bad format' do
    post "/users/#{@user.user_auth_token}/offered_awards", params: {
      description: 'desc', picture: 'nil',
      price: 564
    }, headers: authorization_header(@password, @user.username)
    assert_response :bad_request
    body = JSON.parse(response.body)
    assert_equal 'Invalid attachment', body['message']
  end

  test 'normal users cannot manage awards' do
    @user.update(kind: :normal)
    create_award_post_method
    assert_response :unauthorized
    body = JSON.parse(response.body)
    assert_equal 'You are not allowed to manage awards', body['message']
  end

  def create_award_post_method
    post "/users/#{@user.user_auth_token}/offered_awards", params: {
      title: 'sample award',
      description: 'desc', picture: sample_image_hash,
      price: 564
    }, headers: authorization_header(@password, @user.username)
  end
end
