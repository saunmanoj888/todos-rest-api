class User < ApplicationRecord
  validates_presence_of :username

  has_many :todos, dependent: :destroy
  has_many :items, dependent: :destroy
end
