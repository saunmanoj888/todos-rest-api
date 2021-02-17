require 'rails_helper'

RSpec.describe Item, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:added_by) }
  it { should belong_to(:todo) }
  it { should belong_to(:user) }
end
