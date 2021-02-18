require 'rails_helper'

RSpec.describe User, type: :model do
  it { should validate_presence_of(:username) }
  it { should validate_presence_of(:password) }
  it { should validate_presence_of(:role) }
  it { should validate_inclusion_of(:role).in_array(['Admin', 'Member']) }
  it { should have_many(:todos).with_foreign_key('creator_id').dependent(:destroy).inverse_of(:creator) }
  it { should have_many(:created_items).class_name('Item').with_foreign_key('creator_id').dependent(:restrict_with_error).inverse_of(:creator) }
  it { should have_many(:assigned_items).class_name('Item').with_foreign_key('assignee_id').dependent(:restrict_with_error).inverse_of(:assignee) }
end
