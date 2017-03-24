# Stub
class User < ApplicationRecord
  def authenticate(password)
    password == password_digest ? self : false
  end
end
