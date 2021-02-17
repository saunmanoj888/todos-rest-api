class ItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :added_by, :checked
end
