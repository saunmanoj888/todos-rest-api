class CommentSerializer < ActiveModel::Serializer
  attributes :id, :body, :status
end
