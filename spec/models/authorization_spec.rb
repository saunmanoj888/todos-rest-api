require 'rails_helper'

RSpec.describe Authorization, type: :model do
  it { should validate_uniqueness_of(:role_id).scoped_to(:user_id) }
  it { should belong_to(:user) }
  it { should belong_to(:role) }
end
