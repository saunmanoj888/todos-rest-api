class CommentsController < ApplicationController
  before_action :authorize_user, only: :create
  before_action :set_item, only: %i[index create]
  before_action :validate_item, only: :create
  before_action :validate_comment, only: :index

  def index
    @comments = @item.comments
    json_response(@comments)
  end

  def create
  end

  private

  def set_item
    @item = Item.find(params[:item_id])
  end

  def validate_comment
    return if @item.creator == current_user || @item.assignee == current_user

    render json: { message: 'You are not allowed to view these comments' }, status: :unauthorized
  end

  def validate_item
    return if @item.creator == current_user

    render json: { message: 'This Item does not belongs to you' }, status: :unauthorized
  end
end
