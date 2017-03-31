# Authorizes a request via an authentication token (provided at login user)
class AuthorizeApiRequest
  prepend SimpleCommand

  def initialize(headers = {})
    @headers = headers
  end

  def call
    user
  end

  private

  attr_reader :headers

  def http_auth_header
    auth_header = headers['Authorization']
    return auth_header.split(' ').last if auth_header.present?
    errors.add(:missing_token, 'Missing Authorization Token')
    nil
  end

  def decode_auth_token
    token = http_auth_header
    @decoded_auth_token = JsonWebToken.decode(token) if token
  end

  def user
    decode_auth_token
    @user ||= User.find(@decoded_auth_token[:user_id]) if @decoded_auth_token
    @user || errors.add(:unauthorized, 'Invalid Token') && nil
  end
end
