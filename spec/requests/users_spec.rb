require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  let!(:users) { create_list(:user, 10) }
  let(:user) { create(:user) }
  let(:user_id) { users.first.id }

  describe 'GET /users' do
    before { get '/users' }

    it 'returns users' do
      expect(json).not_to be_empty
      expect(json.size).to eq(10)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /users/:id' do
    before { get "/users/#{user_id}" }

    context 'when the record exists' do
      it 'returns the user' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(user_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:user_id) { 100 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find User/)
      end
    end
  end

  describe 'POST /users' do
    let(:valid_attributes) { { user: { username: 'manoj', password: "qwerty", role: "Admin" } } }

    context 'when the request is valid' do
      before { post '/users', params: valid_attributes }

      it 'creates a user' do
        expect(json['username']).to eq('manoj')
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      before { post '/users', params: { user: { password: "qwerty", role: "Admin" } } }

      it 'returns status code 400' do
        expect(response).to have_http_status(400)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match(/Validation failed: Username can't be blank/)
      end
    end
  end

  describe 'PUT /users/:id' do
    let(:valid_attributes) { { user: { username: 'saun' } } }

    context 'when the record exists' do
      before { put "/users/#{user_id}", params: valid_attributes }

      it 'updates the record' do
        expect(response.body).to be_empty
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end
  end

  describe 'DELETE /users/:id' do
    before { delete "/users/#{user_id}" }

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end
  end

  describe 'POST /Login' do
    let(:valid_attributes) { { user: { username: user.username, password: user.password } } }

    context 'when the credential is valid' do
      before { post '/login', params: valid_attributes }

      it 'logs in successfully' do
        expect(json['user']['username']).to eq(user.username)
      end

      it 'returns a valid token' do
        expect(json['token']).to_not be_empty
      end
    end

    context 'when the credential is invalid' do
      before { post '/login', params: { user: { username: "tech", password: "wrongp" } } }

      it 'returns a validation failure message' do
        expect(json['error']).to eq('Invalid username or password')
      end
    end
  end
end
