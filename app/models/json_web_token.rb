class JsonWebToken < ApplicationRecord
  def self.encode(payload)
    JWT.encode(payload, 's3cr3t')
  end

  def self.decode(token)
    JWT.decode(token, 's3cr3t', true, algorithm: 'HS256')
  end
end
