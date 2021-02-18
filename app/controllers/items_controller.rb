class ItemsController < ApplicationController
  before_action :set_item, only: [:show, :update, :destroy]
  before_action :set_todo, only: [:index, :create]
  before_action :authorize_user, except: [:update, :index, :show]
  before_action :validate_todo, only: [:create, :destroy]
  before_action :validate_item, only: [:update]

  def index
    @items = @todo.items
    json_response(@items)
  end

  def show
    json_response(@item)
  end

  def create
    @item = @todo.items.create!(item_params)
    json_response(@item, :created)
  end

  def update
    @item.update(item_params)
    head :no_content
  end

  def destroy
    @item.destroy
    head :no_content
  end

  private

  def item_params
    params.require(:item).permit(:name, :assignee_id, :checked, :creator_id)
  end

  def set_todo
    @todo = Todo.find(params[:todo_id])
  end

  def set_item
    @item = Item.find(params[:id])
  end

  def validate_todo
    @todo ||= @item.todo
    render json: { message: 'Only todo creator can add item' }, status: :unauthorized unless @todo.creator_id == current_user.id
  end

  def validate_item
    render json: { message: 'Only assignee can perform this task' }, status: :unauthorized unless @item.assignee_id == current_user.id || @item.todo.creator_id == current_user.id
  end
end
