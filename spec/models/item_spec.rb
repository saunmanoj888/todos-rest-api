require 'rails_helper'

RSpec.describe Item, type: :model do
  it { should validate_presence_of(:name) }
  it { should belong_to(:todo) }
  it { should belong_to(:creator).class_name('User').with_foreign_key('creator_id').inverse_of(:created_items) }
  it { should belong_to(:assignee).class_name('User').with_foreign_key('assignee_id').inverse_of(:assigned_items) }

  context 'callbacks' do
    it { is_expected.to callback(:update_todo_status).after(:save) }
  end
end
