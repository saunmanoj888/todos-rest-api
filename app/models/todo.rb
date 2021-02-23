class Todo < ApplicationRecord
  validates_presence_of :title, :status
  validates_inclusion_of :status, in: %w[draft in_progress completed in_active on_hold]
  validate :status_change, if: :status_changed?

  has_many :items, dependent: :destroy
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id', inverse_of: :todos

  before_update :check_all_associated_items, :mark_todos_on_hold, if: :status_changed?

  scope :with_status, ->(status) { where(status: status) }

  def all_items_checked?
    return false if items.blank?

    items.pluck(:checked).exclude?(false)
  end

  private

  TODO_STATUSES = {
    draft:       %w[in_progress],
    in_progress: %w[draft in_active on_hold completed],
    in_active:   %w[on_hold in_progress],
    on_hold:     %w[in_progress],
    completed:   %w[in_progress]
  }.freeze

  def status_change
    return true if TODO_STATUSES[status&.to_sym]&.include? status_was

    errors.add(:base, "Cannnot mark object #{status} from #{status_was}")
  end

  def check_all_associated_items
    items.unchecked_items.update_all(checked: true) if status == 'completed'
  end

  def mark_todos_on_hold
    return if status != 'in_progress'

    remaining_todos  = creator.todos.with_status('in_progress').where.not(id: id)
    remaining_todos.update_all(status: 'on_hold')
  end
end
