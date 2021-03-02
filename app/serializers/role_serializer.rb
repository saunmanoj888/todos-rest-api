class RoleSerializer < ActiveModel::Serializer
  attributes :id, :name, :level
  has_many :permissions
end
