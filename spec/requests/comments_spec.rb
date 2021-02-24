require 'rails_helper'

RSpec.describe "Comments", type: :request do
  let(:admin_user) { create(:user) }
  let(:member_user) { create(:user, role: 'Member') }
  let(:rejected_comment) { create(:comment) }
  let(:item_id) { rejected_comment.item_id }
  let(:item_assigned_to_member) { create(:item, assignee: member_user) }
  let(:comment_2) { create(:comment, item: item_assigned_to_member) }

  describe "GET /comments" do
    before { login }

    context 'When User is Admin' do
      context 'When User searches comments for item created by self' do
        before do
          set_current_user(rejected_comment.creator)
          get "/items/#{item_id}/comments"
        end
        it 'returns comments' do
          expect(json).not_to be_empty
          expect(json.size).to eq(1)
          expect(json.first).to have_key('id')
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      end
      context 'When User searches comments for item not created by self' do
        before do
          set_current_user(admin_user)
          get "/items/#{item_id}/comments"
        end

        it 'returns a validation failure message' do
          expect(response.body).to match(/You are not allowed to view these comments/)
        end
      end
    end
    context 'When User is Member' do
      context 'When User searches comments for item assigned to self' do
        before do
          set_current_user(member_user)
          get "/items/#{comment_2.item_id}/comments"
        end
        it 'returns items' do
          expect(json).not_to be_empty
          expect(json.size).to eq(1)
          expect(json.first).to have_key('id')
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      end
      context 'When User searches comments for item not assigned to self' do
        before do
          set_current_user(member_user)
          get "/items/#{item_id}/comments"
        end

        it 'returns a validation failure message' do
          expect(response.body).to match(/You are not allowed to view these comments/)
        end
      end
    end
  end

  describe "POST /comments" do
    before { login }
    context 'When Admin creates an Item' do
      before { set_current_user(item_assigned_to_member.creator) }
      context 'When Item is assigned to another User' do
        before { item_assigned_to_member }
        context 'When User marks item checked' do
          before { item_assigned_to_member.update_column(:checked, true) }
          context 'When Admin can approve the item' do
            before { post "/items/#{item_assigned_to_member.id}/comments", params: { comment: { body: 'test', status: 'approved' } } }
            it 'creates a comment' do
              expect(json['status']).to eq('approved')
            end
          end
          context 'When Admin can reject the item' do
            before { post "/items/#{item_assigned_to_member.id}/comments", params: { comment: { body: 'test', status: 'rejected' } } }
            it 'creates a comment' do
              expect(json['status']).to eq('rejected')
            end
          end
        end
        context 'When Item is still in unchecked state' do
          before { post "/items/#{item_assigned_to_member.id}/comments", params: { comment: { body: 'test', status: 'approved' } } }
          it 'Admin cannot approve/reject the item' do
            expect(response.body).to match(/This Item cannot be approved/)
          end
        end
      end
    end
  end

end
