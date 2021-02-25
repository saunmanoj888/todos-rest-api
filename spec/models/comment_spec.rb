require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:checked_item) { create(:item, checked: true) }

  it { should validate_inclusion_of(:status).in_array(%w[approved rejected]) }
  it { should belong_to(:item) }
  it { should delegate_method(:creator).to(:item) }

  describe 'callbacks' do
    describe '.uncheck_item' do
      context 'When comment is created with status rejected' do
        it 'marks the item unchecked' do
          expect{
            create(:comment, item: checked_item)
          }.to change(checked_item, :checked).from(true).to(false)
        end
      end
      context 'When comment is created with status approved' do
        it 'does not mark the item unchecked' do
          expect{
            create(:comment, status: 'approved', item: checked_item)
          }.to_not change(checked_item, :checked)
        end
      end
    end
  end
end
