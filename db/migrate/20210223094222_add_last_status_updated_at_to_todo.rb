class AddLastStatusUpdatedAtToTodo < ActiveRecord::Migration[6.1]
  def change
    add_column :todos, :status_changed_at, :datetime
  end
end
