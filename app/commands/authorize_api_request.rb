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
    return headers['Authorization'].split(' ').last if headers['Authorization'].present?
    errors.add(:missing_token, 'Missing Authorization Token')
    nil
  end

  def decode_auth_token
    @decoded_auth_token ||= JsonWebToken.decode(http_auth_header)
  end

  def user
    decode_auth_token
    @user ||= User.find(@decoded_auth_token[:user_id]) if @decoded_auth_token
    @user || errors.add(:unauthorized, 'Invalid Token') && nil
  end
end