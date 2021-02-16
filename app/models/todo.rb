class Todo < ApplicationRecord
  validates_presence_of :title, :created_by, :status

  has_many :items, dependent: :destroy
  belongs_to :user
end
