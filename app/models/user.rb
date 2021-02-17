class User < ApplicationRecord
  has_secure_password
  validates_presence_of :username, :password, :type

  has_many :todos, dependent: :destroy
  has_many :items, dependent: :destroy
end
