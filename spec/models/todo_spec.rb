require 'rails_helper'

RSpec.describe Todo, type: :model do
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:created_by) }
  it { should validate_presence_of(:status) }
  it { should have_many(:items).dependent(:destroy) }
  it { should belong_to(:user) }
end
