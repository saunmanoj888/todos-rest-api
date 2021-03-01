require 'rails_helper'

RSpec.describe Permission, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_inclusion_of(:name).in_array(%w[can_manage_users can_read_users]) }
  it { should have_and_belong_to_many(:roles) }
end
