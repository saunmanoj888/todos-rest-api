class CommentsController < ApplicationController
  include CommentFilter

  before_action :authorize_user, only: :create
  before_action :set_item, only: %i[index create]
  before_action :validate_item, only: :create
  before_action :validate_comment, only: :index
  before_action :validate_item_approval, only: :create

  def index
    json_response(@item.comments)
  end

  def create
    @comment = @item.comments.new(comment_params)
    if @comment.save
      json_response(@comment, :created)
    else
      json_response({ message: @comment.errors.full_messages }, :bad_request)
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body, :status)
  end

  def set_item
    @item = Item.find(params[:item_id])
  end
end
