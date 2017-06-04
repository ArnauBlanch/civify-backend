require 'simplecov'
SimpleCov.start

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  include RewardsConstants
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here

  def auth_token(password, username)
    auth_user = AuthenticateUser.call password, username
    assert auth_user.success?
    auth_user.result
  end

  def authorization_header(password, username)
    { authorization: auth_token(password, username) }
  end

  attr_reader :user, :password

  # options = { username: 'test', kind: :normal }
  def setup_user(options = {})
    options[:username] ||= 'test'
    options[:kind] ||= :normal
    options[:coins] ||= 0
    @password = '1234'
    @user = User.create(username: options[:username],
                        email: "#{options[:username]}@test.com",
                        first_name: options[:username], last_name: options[:username],
                        kind: options[:kind], coins: options[:coins],
                        password: @password, password_confirmation: @password)
    assert @user.valid?
  end

  def setup_issue
    @issue = @user.issues.create(title: 'issue', latitude: 76.4,
                                 longitude: 38.2, category: 'arbolada',
                                 description: 'desc', picture: sample_file,
                                 risk: false, resolved_votes: 564)
    assert @issue.valid?
  end

  def setup_award(price = 0)
    @picture = sample_file
    @award = @user.offered_awards.create!(title: 'award', description: 'desc',
                                          picture: @picture, price: price)
    assert @award.valid?
  end

  def setup_event(options = {})
    options[:enabled] ||= true
    options[:number] ||= 288
    options[:start_date] ||= '2016-05-14'
    options[:end_date] ||= '2018-05-12'
    @event = Event.create(title: 'title', description: 'desc', number: options[:number], coins: 288,
                          xp: 288, kind: :confirm,  image: sample_file, start_date: options[:start_date],
                          end_date: options[:end_date], enabled: options[:enabled])
    assert @event.valid?
    @user.events_in_progress << @event if @user
    @event
  end

  def setup_achievement
    @achievement = Achievement.create(title: 'Title', description:
        'Description', number: 1, kind: :issue, coins: 10, xp: 100)
    assert @achievement.valid?
  end

  def sample_file(filename = 'image.gif')
    File.new("test/fixtures/#{filename}")
  end

  def sample_image_hash
    content = Base64.strict_encode64(File.binread( sample_file))
    { filename: 'image.gif', content: content, content_type: 'image/gif' }
  end

  def setup_reward(user = @user)
    user.update!(coins: 2, xp: 30)
    @before_reward_user = user.dup
  end

  def assert_reward(exp_coins, exp_xp, user = @user)
    assert_reward_no_body(exp_coins, exp_xp, user)
    assert_response_body({ coins: exp_coins, xp: exp_xp }, :rewards)
  end

  def assert_reward_no_body(exp_coins, exp_xp, user = @user)
    user.reload
    assert_equal @before_reward_user.coins + exp_coins, user.coins
    assert_equal @before_reward_user.xp + exp_xp, user.xp
  end

  def assert_reward_not_given
    assert_reward_no_body(0, 0)
    assert_not response_body_has_key?(:rewards)
  end

  # Example usage after setup_user plus call to GET /user/#{@user.user_auth_token}:
  # assert_response_body(:normal, response, :kind)
  # Example usage after call to POST /issues
  # assert_response_body(COINS::ISSUE_CREATION, response, [:rewards, :coins])
  # DO NOT DO .to_json on exp parameter
  # You can compare hashes if needed (even with the entire body without providing any key)
  # keys can contain integers to represent array access
  def assert_response_body(exp, keys = [])
    return unless response
    act = find_in_path(JSON.parse(response.body), keys)
    assert_equal exp.to_json, act.to_json
  end

  def assert_response_body_message(exp)
    assert_response_body exp, :message
  end

  def response_body_has_key?(keys = [])
    return false unless response
    act = find_in_path(JSON.parse(response.body), keys)
    !act.nil?
  end

  private

  def find_in_path(source, keys = [])
    keys = [keys] unless keys.is_a?(Array)
    keys.each do |key|
      key = key.to_s if key.is_a?(Symbol)
      source = source[key]
    end
    source
  end

end
