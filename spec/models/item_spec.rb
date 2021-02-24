require 'rails_helper'

RSpec.describe Item, type: :model do
  let(:item) { create(:item) }
  let(:checked_item) { create(:item, checked: true) }
  it { should validate_presence_of(:name) }
  it { should have_many(:comments).dependent(:destroy) }
  it { should belong_to(:todo) }
  it { should belong_to(:creator).class_name('User').with_foreign_key('creator_id').inverse_of(:created_items) }
  it { should belong_to(:assignee).class_name('User').with_foreign_key('assignee_id').inverse_of(:assigned_items) }

  context 'callbacks' do
    it { is_expected.to callback(:update_todo_status).after(:update).if(:checked_updated?) }
    it { is_expected.to callback(:mark_todo_in_progress).after(:create) }
  end

  context 'Scopes' do
    describe '.unchecked_items' do
      before do
        item
        checked_item
      end
      it "includes all the checked items" do

        expect(Item.unchecked_items).to include(item)
      end

      it "excludes all the unchecked items" do
        expect(Item.unchecked_items).not_to include(checked_item)
      end
    end
  end
end
