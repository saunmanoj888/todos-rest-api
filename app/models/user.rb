class User < ApplicationRecord
  has_secure_password
  validates_presence_of :username, :password, :role
  validates_uniqueness_of :username
  validates_inclusion_of :role, in: %w[Admin Member]

  has_many :todos, foreign_key: 'creator_id', dependent: :destroy, inverse_of: :creator
  has_many :created_items, class_name: 'Item', foreign_key: 'creator_id', dependent: :restrict_with_error, inverse_of: :creator
  has_many :assigned_items, class_name: 'Item', foreign_key: 'assignee_id', dependent: :restrict_with_error, inverse_of: :assignee

  def admin?
    role == 'Admin'
  end
end
