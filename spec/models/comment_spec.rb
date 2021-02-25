require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:checked_item) { create(:item, checked: true) }

  it { should validate_inclusion_of(:status).in_array(%w[approved rejected]) }
  it { should belong_to(:item) }
  it { should delegate_method(:creator).to(:item) }

  describe 'callbacks' do
    describe '.uncheck_item' do
      context 'When comment is created with status rejected' do
        before { create(:comment, item: checked_item) }
        it 'marks the item unchecked' do
          expect(checked_item.checked).to eq(false)
        end
      end
      context 'When comment is created with status approved' do
        before { create(:comment, status: 'approved', item: checked_item) }
        it 'does not mark the item unchecked' do
          expect(checked_item.checked).to eq(true)
        end
      end
    end
  end
end
