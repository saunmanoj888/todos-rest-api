class ItemsController < ApplicationController
  include ItemFilter

  before_action :set_item, only: %i[show update destroy]
  before_action :set_todo, only: %i[index create]
  before_action :authorize_user, except: %i[update show all_items]
  before_action :validate_todo, only: %i[index create destroy]
  before_action :validate_item, only: %i[show update]

  def index
    @items = @todo.items.includes(:creator, :assignee)
    json_response(@items)
  end

  def show
    json_response(@item)
  end

  def create
    @item = @todo.items.new(item_params.merge(creator_id: current_user.id))
    if @item.save
      json_response(@item, :created)
    else
      json_response({ message: @item.errors.full_messages }, :bad_request)
    end
  end

  def update
    if @item.update(item_params)
      json_response(@item)
    else
      json_response({ message: @item.errors.full_messages }, :bad_request)
    end
  end

  def destroy
    if @item.destroy
      json_response({ message: 'Item destroyed successfully' })
    else
      json_response({ message: @item.errors.full_messages }, :bad_request)
    end
  end

  def all_items
    json_response(Item.created_by(current_user.id).or(Item.assigned_to(current_user.id)))
  end

  private

  def item_params
    if current_user.admin?
      params.require(:item).permit(:name, :assignee_id, :checked, :todo_id)
    else
      params.require(:item).permit(:checked)
    end
  end

  def set_todo
    @todo = Todo.find(params[:todo_id])
  end

  def set_item
    @item = Item.find(params[:id])
  end
end
