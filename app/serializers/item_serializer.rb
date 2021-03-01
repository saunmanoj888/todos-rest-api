class ItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :creator_id, :assignee_id, :checked, :todo_id
  has_one :creator
  has_one :assignee
  has_many :comments
end
