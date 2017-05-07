require 'simplecov'
SimpleCov.start

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  include RewardsConstants
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical
  # order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def auth_token(password, username)
    auth_user = AuthenticateUser.call password, username
    assert auth_user.success?
    auth_user.result
  end

  def authorization_header(password, username)
    { authorization: auth_token(password, username) }
  end

  attr_reader :user, :password

  # options = { username = 'test', kind: :normal }
  def setup_user(options = {})
    options[:username] ||= 'test'
    options[:kind] ||= :normal
    @password = '1234'
    @user = User.create(username: options[:username],
                        email: "#{options[:username]}@test.com",
                        first_name: options[:username], last_name: options[:username], kind: options[:kind],
                        password: @password, password_confirmation: @password)
    assert @user.valid?
  end

  def setup_issue
    @picture = sample_file
    @issue = @user.issues.create(title: 'issue', latitude: 76.4,
                                 longitude: 38.2, category: 'arbolada',
                                 description: 'desc', picture: @picture,
                                 risk: false, resolved_votes: 564)
    assert @issue.valid?
  end

  def setup_award
    @picture = sample_file
    @award = @user.offered_awards.create!(title: 'award', description: 'desc',
                                         picture: @picture, price: 564)
    assert @award.valid?
  end

  def sample_file(filename = 'image.gif')
    File.new("test/fixtures/#{filename}")
  end

  def sample_image_hash
    content = Base64.strict_encode64(File.binread sample_file)
    { filename: 'image.gif', content: content, content_type: 'image/gif' }
  end
end
