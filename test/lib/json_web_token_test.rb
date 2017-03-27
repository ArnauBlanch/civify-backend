require 'test_helper'

class JsonWebTokenTest < ActiveSupport::TestCase
  test 'JWT can be encoded and reverted by decoding' do
    jwt_encoded = JsonWebToken.encode(id: 'original_id')
    jwt_decoded = JsonWebToken.decode(jwt_encoded)
    id_decoded = jwt_decoded[:id]
    assert_equal 'original_id', id_decoded,
                 'jwt id decoded matches the original id'
  end

  test 'encoded JWT is the same before expiration' do
    jwt_encoded = JsonWebToken.encode(id: 'original_id')
    jwt_encoded_new = JsonWebToken.encode(id: 'original_id')
    assert_equal jwt_encoded, jwt_encoded_new
  end

  test 'decoding JWT returns nil when is expired' do
    jwt_encoded_expired = JsonWebToken.encode({ id: 'original_id' },
                                              Time.now - 1.hour)
    jwt_decoded_expired = JsonWebToken.decode(jwt_encoded_expired)
    assert_nil jwt_decoded_expired
  end

  test 'encoded JWT is different after expiration' do
    jwt_encoded = JsonWebToken.encode({ id: 'original_id' },
                                      Time.now - 1.hour)
    jwt_encoded_after_expiration = JsonWebToken.encode(id: 'original_id')
    assert_not_equal jwt_encoded, jwt_encoded_after_expiration
  end
end
