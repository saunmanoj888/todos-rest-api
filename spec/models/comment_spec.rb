require 'rails_helper'

RSpec.describe Comment, type: :model do
  it { should validate_inclusion_of(:status).in_array(%w[approved rejected]) }
  it { should belong_to(:item) }
end
