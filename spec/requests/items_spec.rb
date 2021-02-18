require 'rails_helper'

RSpec.describe 'Items API', type: :request do
  let(:user) { create(:user) }
  let!(:item) { create(:item) }
  let(:item_id) { item.id }
  let(:todo_id) { item.todo_id }

  describe 'GET /items' do
    before { get "/todos/#{todo_id}/items" }

    it 'returns items' do
      expect(json).not_to be_empty
      expect(json.size).to eq(1)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /items/:id' do
    before { get "/items/#{item_id}" }

    context 'when the record exists' do
      it 'returns the item' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(item_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:item_id) { 100 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Item/)
      end
    end
  end

  describe 'POST /items' do
    let(:valid_attributes) { { item: { name: 'Learn Elm', creator_id: user.id, checked: false, assignee_id: user.id } } }

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
          .to match(/Validation failed: Creator must exist, Assignee must exist/)
      end
    end
  end

  describe 'PUT /items/:id' do
    let(:valid_attributes) { { item: { checked: true } } }

    context 'when the record exists' do
      before { put "/items/#{item_id}", params: valid_attributes }

      it 'updates the record' do
        expect(response.body).to be_empty
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end
  end

  describe 'DELETE /items/:id' do
    before { delete "/items/#{item_id}" }

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end
  end
end
