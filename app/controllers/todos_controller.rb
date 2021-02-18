class TodosController < ApplicationController
  before_action :set_todo, only: %i[show update destroy]
  before_action :authorize_user, except: %i[index show]
  before_action :validate_todo, only: %i[update destroy]

  def index
    @todos = Todo.all.includes(:items)
    json_response(@todos)
  end

  def show
    json_response(@todo)
  end

  def create
    @todo = Todo.create!(todo_params)
    json_response(@todo, :created)
  end

  def update
    @todo.update(todo_params)
    head :no_content
  end

  def destroy
    @todo.destroy
    head :no_content
  end

  private

  def todo_params
    params.require(:todo).permit(:title, :creator_id, :status)
  end

  def set_todo
    @todo = Todo.find(params[:id])
  end

  def validate_todo
    return if @todo.creator_id == current_user.id

    render json: { message: 'Only creator can perform this task' }, status: :unauthorized
  end
end
