class Todo < ApplicationRecord
  validates_presence_of :title, :status
  validates_inclusion_of :status, in: %w[draft inprogress completed]
  validate :status_change, if: :status_changed?

  has_many :items, dependent: :destroy
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id', inverse_of: :todos

  def completed?
    return false unless items.present?

    items.pluck(:checked).exclude?(false)
  end

  private

  TODO_STATUSES = { draft: %w[inprogress completed], inprogress: %w[draft completed], completed: %w[inprogress] }.freeze

  def status_change
    return true if TODO_STATUSES[status&.to_sym]&.include? status_was

    errors.add(:base, "Cannnot mark object #{status} from #{status_was}") if status_was == 'draft'
  end
end
