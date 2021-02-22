class Todo < ApplicationRecord
  validates_presence_of :title, :status
  validates_inclusion_of :status, in: %w[draft inprogress completed]
  validate :status_change

  has_many :items, dependent: :destroy
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id', inverse_of: :todos

  def completed?
    return false unless items.present?

    items.pluck(:checked).exclude?(false)
  end

  private

  def status_change
    return unless status == 'completed'

    errors.add(:base, 'Can only mark object complete after it was first marked in progress') if status_was == 'draft'
  end
end
