class TodoSerializer < ActiveModel::Serializer
  attributes :id, :title, :created_by, :status

  has_many :items
end
