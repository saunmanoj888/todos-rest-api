require 'rails_helper'

RSpec.describe Item, type: :model do
  let!(:item) { create(:item) }
  let!(:checked_item) { create(:item, checked: true) }
  let(:reject_checked_item) { create(:comment, item: checked_item) }
  let(:inprogress_todo) { create(:todo, status: 'in_progress') }
  let(:unchecked_item) { create(:item, todo: inprogress_todo) }
  let(:item_assigned_to_self) { create(:item, todo: inprogress_todo, assignee: inprogress_todo.creator) }

  it { should validate_presence_of(:name) }
  it { should have_many(:comments).dependent(:destroy) }
  it { should belong_to(:todo) }
  it { should belong_to(:creator).class_name('User').with_foreign_key('creator_id').inverse_of(:created_items) }
  it { should belong_to(:assignee).class_name('User').with_foreign_key('assignee_id').inverse_of(:assigned_items) }

  describe ' Custom validation' do
    describe '.validate_can_uncheck_item' do
      context 'When item is already approved' do
        before do
          item_assigned_to_self.update(checked: true)
          item_assigned_to_self.update(checked: false)
        end
        it 'Item Creator cannot uncheck the item' do
          expect(item_assigned_to_self.errors.full_messages).to include(/Cannnot uncheck, item already approved/)
        end
      end

      context 'When item is not approved' do
        before do
          create(:comment, body: 'item rejected', item: unchecked_item)
          unchecked_item.update(checked: true)
          unchecked_item.update(checked: false)
        end
        it 'Item Creator can uncheck the item' do
          expect(unchecked_item.errors.full_messages).to be_empty
          expect(unchecked_item.checked).to eq(false)
        end
      end
    end
  end

  describe 'callbacks' do
    it { is_expected.to callback(:update_todo_status).after(:update).if(:checked_updated?) }
    it { is_expected.to callback(:mark_todo_in_progress).after(:create) }
    it { is_expected.to callback(:auto_approve).after(:update).if(:checked_updated?) }

    describe '.update_todo_status' do
      context 'When all the items are checked' do
        it 'marks the associated todo as completed' do
          expect {
            unchecked_item.update(checked: true)
          }.to change(unchecked_item.todo, :status).from('in_progress').to('completed')
        end
      end
      context 'When all the items are not checked' do
        before { create(:item, todo: inprogress_todo) }
        it 'does not mark the associated todo as completed' do
          expect {
            unchecked_item.update(checked: true)
          }.to_not change(unchecked_item.todo, :status)
        end
      end
    end

    describe '.auto_approve' do
      context 'When item is marked checked' do
        context 'When item is assigned to the creator himself' do
          it 'auto approve the item' do
            expect {
              item_assigned_to_self.update(checked: true)
            }.to change { Comment.count }.from(0).to(1)
            expect(item_assigned_to_self.comments.pluck(:status)).to include('approved')
          end
        end
        context 'When item is assigned to the another' do
          it 'do not auto approve the item' do
            expect {
              unchecked_item.update(checked: true)
            }.to_not change { Comment.count }
            expect(unchecked_item.comments.pluck(:status)).to be_empty
          end
        end
      end
    end

    describe '.mark_todo_in_progress' do
      context 'When new item is added in completed Todo' do
        before { inprogress_todo.update(status: 'completed') }
        it 'marks the todo as in progress' do
          expect {
            create(:item, todo: inprogress_todo)
          }.to change(inprogress_todo, :status).from('completed').to('in_progress')
        end
      end

      context 'When new item is added in Todo which is not completed' do
        it 'does not mark the todo as in progress' do
          expect { create(:item, todo: inprogress_todo) }.to_not change(inprogress_todo, :status)
        end
      end
    end
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
