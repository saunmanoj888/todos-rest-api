require 'rails_helper'

RSpec.describe User, type: :model do
  it { should validate_presence_of(:username) }
  it { should validate_presence_of(:password) }
  it { should validate_presence_of(:type) }
  it { should validate_inclusion_of(:type).in_array(['Admin', 'Member']) }
  it { should have_many(:todos).dependent(:destroy) }
  it { should have_many(:items).dependent(:destroy) }
end
