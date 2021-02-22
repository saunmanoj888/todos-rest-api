require 'rails_helper'

RSpec.describe Todo, type: :model do
  let(:todo) { create(:todo) }
  let(:unchecked_item) { create(:item) }
  let(:checked_item) { create(:item, checked: true) }

  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:status) }
  it { should validate_inclusion_of(:status).in_array(%w[draft inprogress completed]) }
  it { should have_many(:items).dependent(:destroy) }
  it { should belong_to(:creator).class_name('User').with_foreign_key('creator_id').inverse_of(:todos) }

  describe 'Custom validations' do
    describe 'Status Change' do
      context 'When status is updated from draft to completed' do
        before {todo.update(status: 'completed') }
        it 'returns a validation failure message' do
          expect(todo.errors.full_messages).to eq(['Cannnot mark object completed from draft'])
        end
      end
    end
  end

  describe "#completed?" do

    context 'when items exists' do

      context 'when all the items are checked' do
        it 'returns true' do
          expect(checked_item.todo.completed?).to be true
        end
      end

      context 'when all the items are not checked' do
        it 'returns false' do
          expect(unchecked_item.todo.completed?).to be false
        end
      end

    end

    context 'when items does not exists' do
      it 'returns false' do
        expect(todo.completed?).to be false
      end
    end

  end
end
