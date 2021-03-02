class UserSerializer < ActiveModel::Serializer
  attributes :id, :username, :role
  attributes :comepleted_todo_count, :in_progress_todo_count, :on_hold_to_do_count, :in_active_todo_count
  has_many :roles

  def comepleted_todo_count
    object.todos.with_status('completed').size
  end

  def in_progress_todo_count
    object.todos.with_status('in_progress').size
  end

  def on_hold_to_do_count
    object.todos.with_status('on_hold').size
  end

  def in_active_todo_count
    object.todos.with_status('in_active').size
  end
end
