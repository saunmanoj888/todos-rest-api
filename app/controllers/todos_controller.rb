class TodosController < ApplicationController
  before_action :set_todo, only: %i[show update destroy]
  before_action :authorize_user
  before_action :validate_todo, only: %i[update destroy show]

  def index
    @todos = current_user.todos
    json_response(@todos)
  end

  def show
    json_response(@todo)
  end

  def create
    @todo = Todo.new(todo_params.merge(creator_id: current_user.id))
    if @todo.save
      json_response(@todo, :created)
    else
      json_response({ message: @todo.errors.full_messages }, :bad_request)
    end
  end

  def update
    if @todo.update(todo_params)
      json_response(@todo)
    else
      json_response({ message: @todo.errors.full_messages }, :bad_request)
    end
  end

  def destroy
    if @todo.destroy
      json_response({ message: 'Todo destroyed successfully' })
    else
      json_response({ message: @todo.errors.full_messages }, :bad_request)
    end
  end

  private

  def todo_params
    params.require(:todo).permit(:title, :status)
  end

  def set_todo
    @todo = Todo.find(params[:id])
  end

  def validate_todo
    return if @todo.creator == current_user

    render json: { message: 'Only Todo creator can perform this task' }, status: :unauthorized
  end
end
