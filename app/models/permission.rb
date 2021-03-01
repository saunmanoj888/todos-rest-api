class Permission < ApplicationRecord
  validates_presence_of :name
  validates_inclusion_of :name, in: %w[can_manage_users can_read_users]

  has_and_belongs_to_many :roles
end
