# Encode and decode json web tokens (unique and with expiration)
class JsonWebToken
  TOKEN_EXPIRATION_HOURS = 24
  class << self
    def encode(payload, expiration = TOKEN_EXPIRATION_HOURS.hours.from_now)
      payload[:exp] = expiration.to_i
      JWT.encode payload, Rails.application.secrets.secret_key_base
    end

    def decode(token)
      body = JWT.decode(token, Rails.application.secrets.secret_key_base)[0]
      HashWithIndifferentAccess.new body
    rescue
      nil
    end
  end
end
