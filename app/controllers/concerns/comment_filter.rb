module CommentFilter
  extend ActiveSupport::Concern

  included do
    def validate_comment
      return if @item.creator == current_user || @item.assignee == current_user

      render json: { message: 'You are not allowed to view these comments' }, status: :unauthorized
    end

    def validate_item
      return if @item.creator == current_user

      render json: { message: 'This Item does not belongs to you' }, status: :unauthorized
    end

    def validate_item_approval
      return if @item.can_approve_or_reject?

      render json: { message: 'This Item cannot be approved' }, status: :unauthorized
    end
  end
end
