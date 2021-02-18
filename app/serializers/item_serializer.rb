class ItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :creator_id, :assignee_id, :checked
end
