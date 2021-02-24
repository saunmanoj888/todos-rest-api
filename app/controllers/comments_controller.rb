class CommentsController < ApplicationController
  before_action :authorize_user, only: :create
  before_action :set_item, only: :index

  def index
  end

  def create
  end

  private

  def set_item
    @item = Item.find(params[:item_id])
  end
end
