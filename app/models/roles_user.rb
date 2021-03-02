class RolesUser < ApplicationRecord
  validates_uniqueness_of :role_id, scope: :user_id
  # add validation to expiry_date( should be greater than Time.zone.now)

  belongs_to :user
  belongs_to :role

  scope :without_expiry_date, -> { where(expiry_date: nil) }
  scope :active_having_expiry_date, -> { where("expiry_date >= ?", Time.zone.now) }
end
