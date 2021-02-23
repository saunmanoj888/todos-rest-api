class MarkTodosInactiveJob < ApplicationJob
  queue_as :default

  def perform(*args)
    todos = Todo.where("status_changed_at < ?", Time.zone.now - 14.days).where(status: %w[in_progress on_hold])
    todos.update_all(status: 'in_active') if todos.present?
  end
end
