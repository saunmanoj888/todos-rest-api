require 'rails_helper'

RSpec.describe Item, type: :model do
  let!(:item) { create(:item) }
  let!(:checked_item) { create(:item, checked: true) }
  let(:reject_checked_item) { create(:comment, item: checked_item) }
  it { should validate_presence_of(:name) }
  it { should have_many(:comments).dependent(:destroy) }
  it { should belong_to(:todo) }
  it { should belong_to(:creator).class_name('User').with_foreign_key('creator_id').inverse_of(:created_items) }
  it { should belong_to(:assignee).class_name('User').with_foreign_key('assignee_id').inverse_of(:assigned_items) }

  describe 'callbacks' do
    it { is_expected.to callback(:update_todo_status).after(:update).if(:checked_updated?) }
    it { is_expected.to callback(:mark_todo_in_progress).after(:create) }
  end

  describe 'Scopes' do
    describe '.unchecked_items' do
      it "includes all the checked items" do

        expect(Item.unchecked_items).to include(item)
      end

      it "excludes all the unchecked items" do
        expect(Item.unchecked_items).not_to include(checked_item)
      end
    end
  end

  describe '#can_approve_or_reject?' do
    context 'when item is checked' do
      context 'when no comments are present for item' do
        it 'returns true' do
          expect(checked_item.can_approve_or_reject?).to eq(true)
        end
      end
      context 'when item is rejected and not approved yet' do
        before do
          reject_checked_item
          allow(checked_item).to receive(:checked).and_return(true)
        end
        it 'returns true' do
          expect(checked_item.can_approve_or_reject?).to eq(true)
        end
      end
      context 'when item is approved after multiple rejections' do
        before do
          create(:comment, item: checked_item)
          create(:comment, status: 'approved', item: checked_item)
        end
        it 'returns false' do
          expect(checked_item.can_approve_or_reject?).to eq(false)
        end
      end
    end
    context 'when item is unchecked' do
      it 'returns false' do
        expect(item.can_approve_or_reject?).to eq(false)
      end
    end
  end
end
