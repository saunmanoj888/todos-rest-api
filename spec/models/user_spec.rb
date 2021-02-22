require 'rails_helper'

RSpec.describe User, type: :model do
  let(:admin_user) { create(:user) }
  let(:member_user) { create(:user, role: "Member") }

  it { should validate_presence_of(:username) }
  it { should validate_uniqueness_of(:username) }
  it { should validate_presence_of(:password) }
  it { should validate_presence_of(:role) }
  it { should validate_inclusion_of(:role).in_array(['Admin', 'Member']) }
  it { should have_many(:todos).with_foreign_key('creator_id').dependent(:destroy).inverse_of(:creator) }
  it { should have_many(:created_items).class_name('Item').with_foreign_key('creator_id').dependent(:restrict_with_error).inverse_of(:creator) }
  it { should have_many(:assigned_items).class_name('Item').with_foreign_key('assignee_id').dependent(:restrict_with_error).inverse_of(:assignee) }

  describe "#admin?" do

    context 'when user has admin rights' do
      it 'returns true' do
        expect(admin_user.admin?).to be true
      end
    end

    context 'when user does not have admin rights' do
      it 'returns false' do
        expect(member_user.admin?).to be false
      end
    end

  end
end
