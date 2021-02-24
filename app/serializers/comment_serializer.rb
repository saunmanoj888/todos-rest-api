class CommentSerializer < ActiveModel::Serializer
  attributes :id, :body, :status
  belongs_to :item
end
