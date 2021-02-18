class Item < ApplicationRecord
  validates_presence_of :name

  belongs_to :todo
  belongs_to :creator, class_name: "User", foreign_key: "creator_id", inverse_of: :created_items
  belongs_to :assignee, class_name: "User", foreign_key: "assignee_id", inverse_of: :assigned_items

  after_update :update_todo_status, if: :checked_changed?

  private

  def update_todo_status
    if todo.completed?
      todo.update_column(:status, 'completed')
    else
      todo.update_column(:status, 'inprogress')
    end
  end
end
