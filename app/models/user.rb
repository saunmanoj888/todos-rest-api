class User < ApplicationRecord
  has_secure_password
  validates_presence_of :username, :password, :role
  validates_uniqueness_of :username
  validates_inclusion_of :role, in: %w[Admin Member]
  validates :email, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  has_many :todos, foreign_key: 'creator_id', dependent: :destroy, inverse_of: :creator
  has_many :created_items, class_name: 'Item', foreign_key: 'creator_id', dependent: :restrict_with_error, inverse_of: :creator
  has_many :assigned_items, class_name: 'Item', foreign_key: 'assignee_id', dependent: :restrict_with_error, inverse_of: :assignee
  has_many :roles_users, dependent: :destroy
  has_many :roles, through: :roles_users

  def admin?
    role == 'Admin'
  end


  def can_access_permission?(permission_name)
    role_ids = active_roles_users.pluck(:role_id)
    Role.includes(:permissions).where(id: role_ids, permissions: { name: permission_name }).present?
  end

  def max_role_level
    role_ids = active_roles_users.pluck(:role_id)
    Role.where(id: role_ids).pluck(:level).max || 0
  end

  def active_roles_users
    roles_users.active_having_expiry_date.or(roles_users.without_expiry_date)
  end
end
