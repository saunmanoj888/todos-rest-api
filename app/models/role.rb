class Role < ApplicationRecord
  validates_presence_of :name, :level
  has_many :authorizations
  has_many :users, through: :authorizations
  has_and_belongs_to_many :permissions
end
