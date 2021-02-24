class Item < ApplicationRecord
  validates_presence_of :name

  has_many :comments, dependent: :destroy
  belongs_to :todo
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id', inverse_of: :created_items
  belongs_to :assignee, class_name: 'User', foreign_key: 'assignee_id', inverse_of: :assigned_items

  after_update :update_todo_status, if: :checked_updated?

  after_create :mark_todo_in_progress

  scope :unchecked_items, -> { where(checked: false) }

  def can_approve_or_reject?
    checked && !comments.pluck(:status).include?('approved')
  end

  private

  def checked_updated?
    saved_changes[:checked].present?
  end

  def update_todo_status
    if todo.all_items_checked? && todo.status != 'completed'
      todo.update_column(:status, 'completed')
    end
  end

  def mark_todo_in_progress
    if todo.status == 'completed'
      todo.update_attribute(:status, 'in_progress')
    end
  end
end
