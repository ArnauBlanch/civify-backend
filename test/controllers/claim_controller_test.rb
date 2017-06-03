require 'test_helper'

class ClaimControllerTest < ActionDispatch::IntegrationTest
  def setup
    setup_user(kind: :normal)
  end

  test 'achievement does not exist' do
    post '/achievements/111/claim',
         headers: authorization_header(@password, @user.username)
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal 'Achievement does not exist', body['message']
  end

  test 'achievement claimed succesfully' do
    setup_user(kind: :admin, username: 'admin-user')
    create_achievement
    a = Achievement.find_by(number: 5, kind: 'issue')
    user = User.find_by(kind: :normal)
    user.achievement_progresses
        .find_by(achievement_id: a.id)
        .update(completed: true, claimed: false)
    post "/achievements/#{a.achievement_token}/claim",
         headers: authorization_header(@password, user.username)
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal a.coins, body['coins']
    assert_equal a.xp, body['xp']
  end

  test 'achievement already claimed' do
    setup_user(kind: :admin, username: 'admin-user')
    create_achievement
    a = Achievement.find_by(number: 5, kind: 'issue')
    user = User.find_by(kind: :normal)
    user.achievement_progresses
        .find_by(achievement_id: a.id)
        .update(completed: true, claimed: true)
    post "/achievements/#{a.achievement_token}/claim",
         headers: authorization_header(@password, user.username)
    assert_response :bad_request
    body = JSON.parse(response.body)
    assert_equal 'You have already claimed this achievement',
                 body['message']
  end

  test 'achievement not completed' do
    setup_user(kind: :admin, username: 'admin-user')
    create_achievement
    a = Achievement.find_by(number: 5, kind: 'issue')
    user = User.find_by(kind: :normal)
    user.achievement_progresses
        .find_by(achievement_id: a.id)
        .update(completed: false, claimed: false)
    post "/achievements/#{a.achievement_token}/claim",
         headers: authorization_header(@password, user.username)
    assert_response :bad_request
    body = JSON.parse(response.body)
    assert_equal 'You haven\'t completed this achievement yet',
                 body['message']
  end

  test 'admin user trying to claim an achievement' do
    setup_user(kind: :admin, username: 'admin-user')
    create_achievement
    a = Achievement.find_by(number: 5, kind: 'issue')
    post "/achievements/#{a.achievement_token}/claim",
         headers: authorization_header(@password, @user.username)
    assert_response :unauthorized
    body = JSON.parse(response.body)
    assert_equal 'You are not allowed to perform this action.',
                 body['message']
  end

  test 'business user trying to claim an achievement' do
    setup_user(kind: :admin, username: 'admin-user')
    create_achievement
    a = Achievement.find_by(number: 5, kind: 'issue')
    @user.update(kind: :business)
    post "/achievements/#{a.achievement_token}/claim",
         headers: authorization_header(@password, @user.username)
    assert_response :unauthorized
    body = JSON.parse(response.body)
    assert_equal 'You are not allowed to perform this action.',
                 body['message']
  end

  private

  def create_achievement
    post '/achievements', headers: authorization_header(@password, @user.username), params: {
        title: 'Title', description: 'Description',
        number: 5, kind: :issue, coins: 10, xp: 100
    }, as: :json
    assert_response :created
  end
end
