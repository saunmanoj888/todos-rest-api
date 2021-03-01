class Authorization < ApplicationRecord
  validates_uniqueness_of :role_id, scope: :user_id

  belongs_to :user
  belongs_to :role
end
