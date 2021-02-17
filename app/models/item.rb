class Item < ApplicationRecord
  validates_presence_of :name, :added_by
  belongs_to :todo
  belongs_to :user
end
