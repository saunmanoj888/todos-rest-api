class TodoSerializer < ActiveModel::Serializer
  attributes :id, :title, :creator_id, :status

  has_many :items
end
