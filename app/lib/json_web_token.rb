class JsonWebToken

  TOKEN_DURATION_HOURS = 24

  class << self
    def encode(payload, expiration = TOKEN_DURATION_HOURS.hours.from_now)
      payload[:expiration] = expiration.to_i
      JWT.encode(payload, Rails.application.secrets.secret_key_base)
    end

    def decode(token)
      body = JWT.decode(token, Rails.application.secrets.secret_key_base)[0]
      HashWithIndifferentAccess.new body
    rescue
      nil
    end
  end
end