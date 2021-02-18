class Todo < ApplicationRecord
  validates_presence_of :title, :status

  has_many :items, dependent: :destroy
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id', inverse_of: :todos

  def completed?
    return false unless items.present?

    items.pluck(:checked).exclude?(false)
  end
end
