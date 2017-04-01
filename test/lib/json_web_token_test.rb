require 'test_helper'

class JsonWebTokenTest < ActiveSupport::TestCase
  test 'JWT can be encoded and reverted by decoding' do
    jwt_decoded = JsonWebToken.decode(encode)
    id_decoded = jwt_decoded[:id]
    assert_equal 'original_id', id_decoded,
                 'jwt id decoded matches the original id'
  end

  test 'encoded JWT is the same before expiration' do
    assert_equal encode, encode
  end

  test 'decoding expired JWT returns nil' do
    assert_nil JsonWebToken.decode(encode_expired)
  end

  test 'encoded JWT is different after expiration' do
    assert_not_equal encode_expired, encode
  end

  def encode(id = 'original_id', expiration = nil)
    if expiration.nil?
      JsonWebToken.encode id: id
    else
      JsonWebToken.encode({ id: id }, expiration)
    end
  end

  def encode_expired
    encode 'original_id',Time.now - 1.hour
  end
end
