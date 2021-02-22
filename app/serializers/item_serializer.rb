class ItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :creator_id, :assignee_id, :checked, :todo_id
  belongs_to :creator
  belongs_to :assignee
end
