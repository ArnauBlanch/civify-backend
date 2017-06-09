require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    setup_user(username: 'test_mailer')
  end

  test 'password resets' do
    # Invalid email
    post '/password_resets', params: { password_reset: { email: '' } }, as: :json
    assert_response :not_found
    assert_response_body_message 'User does not exist'
    # Valid email
    post '/password_resets', params: { password_reset: { email: @user.email } }, as: :json
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_response :ok
    assert_response_body_message 'Email sent'
    @user.create_reset_digest
    # Invalid password & confirmation
    patch "/password_resets/#{@user.reset_token}",
          params: { email: @user.email,
                    user: { password: 'foobaz',
                            password_confirmation: 'barquux' } }
    assert_response :unprocessable_entity
    assert_response_body_message 'Invalid passwords'
    # Empty password
    patch "/password_resets/#{@user.reset_token}",
          params: { email: @user.email,
                    user: { password: '',
                            password_confirmation: '' } }
    assert_response :unprocessable_entity
    assert_response_body_message 'Password can\'t be blank'
    # Invalid reset token
    patch '/password_resets/1111',
          params: { email: @user.email,
                    user: { password: 'foobaz',
                            password_confirmation: 'barquux' } }
    assert_response :bad_request
    assert_response_body_message 'Invalid token'
    # Expired reset token
    reset_sent_at_backup = @user.reset_sent_at
    @user.update(reset_sent_at: (@user.reset_sent_at - 3.days))
    patch "/password_resets/#{@user.reset_token}",
          params: { email: @user.email,
                    user: { password: 'foobaz',
                            password_confirmation: 'barquux' } }
    assert_response :unauthorized
    assert_response_body_message 'The password reset token has expired'
    # Valid password & confirmation
    @user.update(reset_sent_at: reset_sent_at_backup)
    patch "/password_resets/#{@user.reset_token}",
          params: { email: @user.email,
                    user: { password: 'foobaz',
                            password_confirmation: 'foobaz' } }
    assert_response :ok
    assert_response_body_message 'Password reseted successfully'
    assert_not_equal @user.password_digest, @user.reload.password_digest
    assert @user.authenticate('foobaz')
    assert_not @user.authenticate(@password)
  end

end
