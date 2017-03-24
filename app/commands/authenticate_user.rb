class AuthenticateUser
  prepend SimpleCommand

  def initialize(username = nil, email = nil, password)
    @username = username
    @email = email
    @password = password
  end

  def call
    if password
      if username || email
        JsonWebToken.encode(user_id: user.id) if user
      else
        errors.add :missing_parameters, 'username or email must be provided'
      end
    else errors.add :missing_parameters, 'password must be provided'
    end
  end

  private

  attr_accessor :username, :email, :password

  def user
    user = User.find_by_username(username) if username
    user ||= User.find_by_email(email)
    if user
      return user if user.authenticate(password)
      errors.add :invalid_credentials, 'Invalid credentials'
    else
      errors.add :not_found, 'User not exists'
    end
  end
end