class Item < ApplicationRecord
  validates_presence_of :name, :added_by, :checked
  belongs_to :todo
  belongs_to :user
end
