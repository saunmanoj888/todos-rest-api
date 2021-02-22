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
    @todo.save!
    json_response(@todo, :created)
  end

  def update
    @todo.update!(todo_params)
    json_response(@todo)
  end

  def destroy
    @todo.destroy
    head :no_content
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
