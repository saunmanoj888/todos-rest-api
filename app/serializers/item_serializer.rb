class ItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :creator_id, :assignee_id, :checked, :todo_id, :comments
  belongs_to :creator
  belongs_to :assignee

  def comments
    ActiveModel::SerializableResource.new(object.comments,  each_serializer: CommentSerializer)
  end
end
