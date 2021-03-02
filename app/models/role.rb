class Role < ApplicationRecord
  validates_presence_of :name, :level
  has_many :roles_users, dependent: :destroy
  has_many :users, through: :roles_users
  has_and_belongs_to_many :permissions
end
