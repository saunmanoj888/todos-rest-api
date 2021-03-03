class Item < ApplicationRecord
  validates_presence_of :name
  validate :validate_can_uncheck_item, if: :checked_changed?

  has_many :comments, dependent: :destroy
  belongs_to :todo
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id', inverse_of: :created_items
  belongs_to :assignee, class_name: 'User', foreign_key: 'assignee_id', inverse_of: :assigned_items

  after_update :update_todo_status, if: :checked_updated?
  after_update :auto_approve, if: :checked_updated?

  after_create :mark_todo_in_progress

  scope :unchecked_items, -> { where(checked: false) }
  scope :assigned_to, ->(user_id) { where("assignee_id = ?", user_id) }
  scope :created_by, ->(user_id) { where("creator_id = ?", user_id) }


  def can_approve_or_reject?
    checked && !previously_approved?
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

  def auto_approve
    if checked && (creator == assignee)
      comments.create(body: 'auto approved', status: 'approved')
    end
  end

  def validate_can_uncheck_item
    if previously_approved?
      errors.add(:base, "Cannnot uncheck, item already approved")
    end
  end

  def previously_approved?
    comments.pluck(:status).include?('approved')
  end
end
