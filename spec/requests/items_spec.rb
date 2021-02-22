require 'rails_helper'

RSpec.describe 'Items API', type: :request do
  let(:admin_user) { create(:user) }
  let(:member_user) { create(:user, role: 'Member') }
  let!(:item) { create(:item) }
  let(:item_id) { item.id }
  let(:todo_id) { item.todo_id }
  let(:item_assigned_to_member) { create(:item, assignee: member_user) }
  let(:item_assigned_to_admin) { create(:item, assignee: admin_user) }

  describe 'GET /items' do
    before { login }

    context 'When User is Admin' do
      context 'When User searches items for todo created by self' do
        before { set_current_user(item.creator) }
        before { get "/todos/#{todo_id}/items" }
        it 'returns items' do
          expect(json).not_to be_empty
          expect(json.size).to eq(1)
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      end
      context 'When User searches items for todo not created by self' do
        before { set_current_user(admin_user) }
        before { get "/todos/#{todo_id}/items" }
        it 'returns a validation failure message' do
          expect(response.body).to match(/This Todo does not belongs to you/)
        end
      end
    end
    context 'When User is Member' do
      before { set_current_user(member_user) }
      before { get "/todos/#{todo_id}/items" }
      it 'returns a validation failure message' do
        expect(response.body).to match(/Only admin can perform this task/)
      end
    end
  end

  describe 'GET /items/:id' do
    before { login }

    context 'When User is Admin' do
      context 'When record exists' do
        context 'When item is assigned to User' do
          before { set_current_user(admin_user) }
          before { get "/items/#{item_assigned_to_admin.id}" }

          it 'returns the item' do
            expect(json).not_to be_empty
            expect(json['id']).to eq(item_assigned_to_admin.id)
          end

          it 'returns status code 200' do
            expect(response).to have_http_status(200)
          end
        end
        context 'When item is created by User' do
          before { set_current_user(item.creator) }
          before { get "/items/#{item.id}" }

          it 'returns the item' do
            expect(json).not_to be_empty
            expect(json['id']).to eq(item.id)
          end
        end
        context 'When item neither created by/assigned to User' do
          before { set_current_user(admin_user) }
          before { get "/items/#{item_id}" }
          it 'returns a validation failure message' do
            expect(response.body).to match(/Item does not belongs to the User/)
          end
        end
      end
      context 'when the record does not exist' do
        before { set_current_user(admin_user) }
        before { get '/items/100' }
        it 'returns status code 404' do
          expect(response).to have_http_status(404)
        end

        it 'returns a not found message' do
          expect(response.body).to match(/Couldn't find Item/)
        end
      end
    end

    context 'When User is Member' do
      context 'When item is assigned to User' do
        before { set_current_user(member_user) }
        before { get "/items/#{item_assigned_to_member.id}" }
        it 'returns the item' do
          expect(json).not_to be_empty
          expect(json['id']).to eq(item_assigned_to_member.id)
        end
      end
      context 'When item is not assigned to User' do
        before { set_current_user(member_user) }
        before { get "/items/#{item_id}" }
        it 'returns a validation failure message' do
          expect(response.body).to match(/Item does not belongs to the User/)
        end
      end
    end
  end

  describe 'POST /items' do
    before { login }
    let(:valid_attributes) { { item: { name: 'Learn Elm', creator_id: item.creator_id, checked: false, assignee_id: item.creator_id } } }

    context 'when user is admin' do
      context 'when todo belongs to user' do
        before { set_current_user(item.creator) }
        context 'when the request is valid' do
          before { post "/todos/#{todo_id}/items", params: valid_attributes }

          it 'creates an item' do
            expect(json['name']).to eq('Learn Elm')
          end

          it 'returns status code 201' do
            expect(response).to have_http_status(201)
          end
        end

        context 'when the request is invalid' do
          before { post "/todos/#{todo_id}/items", params: { item: { name: 'Foobar' } } }

          it 'returns status code 400' do
            expect(response).to have_http_status(400)
          end

          it 'returns a validation failure message' do
            expect(response.body)
              .to match(/Validation failed: Assignee must exist/)
          end
        end
      end
      context 'when todo does not belong to user' do
        before { set_current_user(admin_user) }
        before { post "/todos/#{todo_id}/items", params: valid_attributes }
        it 'returns a validation failure message' do
          expect(response.body).to match(/This Todo does not belongs to you/)
        end
      end
    end

    context 'when user is Member' do
      before { set_current_user(member_user) }
      before { post "/todos/#{todo_id}/items", params: valid_attributes }
      it 'returns a validation failure message' do
        expect(response.body).to match(/Only admin can perform this task/)
      end
    end
  end

  describe 'PUT /items/:id' do
    before { login }
    let(:valid_attributes) { { item: { checked: true } } }

    context 'when user is admin' do

      context 'when todo belongs to the user' do
        before { set_current_user(item.creator) }
        before { put "/items/#{item_id}", params: valid_attributes }

        it 'updates the record' do
          expect(json['checked']).to eq(true)
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      end

      context 'when todo does not belongs to the user' do

        before { set_current_user(admin_user) }
        before { put "/items/#{item_id}", params: valid_attributes }

        it 'returns a validation failure message' do
          expect(response.body).to match(/Item does not belongs to the User/)
        end
      end

    end

    context 'when user is Member' do

      before { set_current_user(member_user) }

      context 'When item is assigned to the User' do
        context 'When User only updates Checked' do
          before { put "/items/#{item_assigned_to_member.id}", params: valid_attributes }
          it 'updates the record' do
            expect(json['checked']).to eq(true)
          end
        end
        context 'When User updates details other than checked' do
          before { put "/items/#{item_assigned_to_member.id}", params: { item: { checked: true, name: 'test' } } }
          it 'does not change any other details except checked' do
            expect(json['name']).to_not eq('test')
            expect(json['checked']).to eq(true)
          end
        end
      end

      context 'When item is not assigned to the User' do
        before { put "/items/#{item.id}", params: valid_attributes }
        it 'returns a validation failure message' do
          expect(response.body).to match(/Item does not belongs to the User/)
        end
      end

    end

  end

  describe 'DELETE /items/:id' do
    before { login }

    context 'when user is admin' do

      context 'when todo belongs to user' do

        before { set_current_user(item.creator) }
        before { delete "/items/#{item_id}" }

        it 'returns status code 204' do
          expect(response).to have_http_status(204)
        end
      end

      context 'when todo does not belongs to user' do

        before { set_current_user(admin_user) }
        before { delete "/items/#{item_id}" }

        it 'returns a validation failure message' do
          expect(response.body).to match(/This Todo does not belongs to you/)
        end

      end

    end

    context 'when user is not admin' do

      before{ set_current_user(member_user) }
      before { delete "/items/#{item_id}" }

      it 'returns a validation failure message' do
        expect(response.body).to match(/Only admin can perform this task/)
      end

    end
  end

  describe 'GET /all_items' do
    before { login }
    context 'When User is Admin' do
      before do
        set_current_user(admin_user)
        item_assigned_to_member
        item_assigned_to_admin
        get '/all_items'
      end

      it 'returns all the items assigned/created for User' do
        expect(json).not_to be_empty
        expect(json.size).to eq(1)
      end
    end
    context 'When User is Member' do
      before do
        set_current_user(member_user)
        item_assigned_to_member
        item_assigned_to_admin
        get '/all_items'
      end
      it 'returns all the items assigned to the User' do
        expect(json).not_to be_empty
        expect(json.size).to eq(1)
      end
    end
  end
end
