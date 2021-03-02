module ItemFilter
  extend ActiveSupport::Concern

  included do
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
end
