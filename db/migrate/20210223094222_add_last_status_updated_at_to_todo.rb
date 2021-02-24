class AddLastStatusUpdatedAtToTodo < ActiveRecord::Migration[6.1]
  def change
    add_column :todos, :status_updated_at, :datetime
  end
end
