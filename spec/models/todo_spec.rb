require 'rails_helper'

RSpec.describe Todo, type: :model do
  let(:item) { create(:item) }
  let(:todo) { create(:todo) }
  let(:in_progress_todo) { create(:todo, status: 'in_progress', creator: todo.creator) }
  let(:unchecked_item) { create(:item) }
  let(:checked_item) { create(:item, checked: true) }

  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:status) }
  it { should validate_inclusion_of(:status).in_array(%w[draft in_progress completed in_active on_hold]) }
  it { should have_many(:items).dependent(:destroy) }
  it { should belong_to(:creator).class_name('User').with_foreign_key('creator_id').inverse_of(:todos) }

  describe 'callbacks' do
    it { is_expected.to callback(:check_all_associated_items).before(:update).if(:status_changed?) }
    it { is_expected.to callback(:mark_todos_on_hold).before(:update).if(:status_changed?) }
    it { is_expected.to callback(:set_status_updated_at).before(:save).if(:status_changed?) }

    describe 'When todo is marked complete' do
      before do
        in_progress_todo
        create(:item, todo: in_progress_todo)
        in_progress_todo.update!(status: 'completed')
      end
      it 'all associated unchecked items should be checked' do
        expect(in_progress_todo.reload.items.pluck(:checked)).to_not include(false)
      end
    end

    describe 'When todo is marked in progress' do
      before do
        todo
        in_progress_todo
        todo.update(status: 'in_progress')
      end
      it 'remaining in progress todos should be on hold' do
        expect(in_progress_todo.reload.status).to eq('on_hold')
      end
    end

    describe 'When todo is created' do
      before { todo }
      it 'status_updated_at should not be set' do
        expect(todo.status_updated_at).to eq(nil)
      end
    end

    describe 'When todo status is updated' do
      before { todo.update(status: 'in_progress') }
      it 'status_updated_at also gets updated' do
        expect(todo.status_updated_at).to_not eq(nil)
      end
    end
  end

  describe 'Custom validations' do
    describe 'Validate Status Change' do
      context 'When status is updated from draft to completed' do
        before {todo.update(status: 'completed') }
        it 'returns a validation failure message' do
          expect(todo.errors.full_messages).to eq(['Cannnot mark object completed from draft'])
        end
      end
    end
  end

  describe 'Scopes' do
    describe '.with_status' do
      before do
        todo
        in_progress_todo
      end

      it "includes all the todos with status draft" do
        expect(Todo.with_status('draft')).to include(todo)
      end
      it "excludes all the todos with except draft" do
        expect(Todo.with_status('draft')).to_not include(in_progress_todo)
      end
    end
  end

  describe "#all_items_checked?" do

    context 'when items exists' do

      context 'when all the items are checked' do
        it 'returns true' do
          expect(checked_item.todo.all_items_checked?).to be true
        end
      end

      context 'when all the items are not checked' do
        it 'returns false' do
          expect(unchecked_item.todo.all_items_checked?).to be false
        end
      end

    end

    context 'when items does not exists' do
      it 'returns false' do
        expect(todo.all_items_checked?).to be false
      end
    end

  end
end
