class Comment < ApplicationRecord
  validates_inclusion_of :status, in: %w[approved rejected]

  belongs_to :item

  delegate :creator, to: :item

  after_create :uncheck_item

  private

  def uncheck_item
    if status == 'rejected'
      item.update_column(:checked, false)
    end
  end
end
