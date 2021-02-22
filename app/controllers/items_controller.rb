class ItemsController < ApplicationController
  before_action :set_item, only: %i[show update destroy update_checked]
  before_action :set_todo, only: %i[index create]
  before_action :authorize_user, except: %i[show all_items update_checked]
  before_action :validate_todo, only: %i[index create destroy update]
  before_action :validate_item, only: %i[show update update_checked]

  def index
    @items = @todo.items.includes(:creator, :assignee)
    json_response(@items)
  end

  def show
    json_response(@item)
  end

  def create
    @item = @todo.items.new(item_params)
    @item.creator = current_user
    @item.save!
    json_response(@item, :created)
  end

  def update
    @item.update!(item_params)
    json_response(@item)
  end

  def destroy
    @item.destroy
    head :no_content
  end

  def all_items
    @items = Item.where(creator_id: current_user).or(Item.where(assignee: current_user))
    json_response(@items)
  end

  def update_checked
    @item.update!(checked: params[:item][:checked])
    json_response(@item)
  end

  private

  def item_params
    params.require(:item).permit(:name, :assignee_id, :checked, :todo_id)
  end

  def set_todo
    @todo = Todo.find(params[:todo_id])
  end

  def set_item
    @item = Item.find(params[:id])
  end

  def validate_todo
    @todo ||= @item.todo
    return if @todo.creator == current_user

    render json: { message: 'This Todo does not belongs to you' }, status: :unauthorized
  end

  def validate_item
    return if @item.assignee == current_user || @item.todo.creator == current_user

    render json: { message: 'Item does not belongs to the User' }, status: :unauthorized
  end
end
