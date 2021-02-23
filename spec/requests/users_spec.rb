require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  let!(:users) { create_list(:user, 10) }
  let(:admin_user) { create(:user) }
  let(:member_user) { create(:user, role: 'Member') }
  let(:user_id) { users.first.id }

  describe 'GET /users' do
    before { login }

    context 'when User with Admin roles logs in' do
      before do
        set_current_user(admin_user)
        get '/users'
      end

      it 'returns all users' do
        expect(json).not_to be_empty
        expect(json.size).to eq(11)
        expect(json.first).to have_key('id')
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end
    context 'when User with Member roles logs in' do
      before do
        set_current_user(member_user)
        get '/users'
      end

      it 'returns details of self' do
        expect(json).not_to be_empty
        expect(json.size).to eq(1)
        expect(json.first).to have_key('id')
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /users/:id' do
    before { login }

    context 'when User is Admin' do
      before do
        set_current_user(admin_user)
        get "/users/#{user_id}"
      end

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

    context 'when User is not Admin' do
      before do
        set_current_user(member_user)
        get "/users/#{user_id}"
      end

      it 'returns a validation message' do
        expect(response.body).to match(/Only admin can perform this task/)
      end
    end
  end

  describe 'POST /users' do
    before { login }
    let(:valid_attributes) { { user: { username: 'manoj', password: 'qwerty', role: 'Admin' } } }

    context 'when User with Admin role logs in' do
      before { set_current_user(admin_user) }
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
        before { post '/users', params: { user: { password: 'qwerty', role: 'Admin' } } }

        it 'returns status code 400' do
          expect(response).to have_http_status(400)
        end

        it 'returns a validation failure message' do
          expect(response.body).to match(/Username can't be blank/)
        end
      end
    end
    context 'when User with Member role logs in' do
      before do
        set_current_user(member_user)
        post '/users', params: valid_attributes
      end

      it 'returns a validation message' do
        expect(response.body).to match(/Only admin can perform this task/)
      end
    end
  end

  describe 'PUT /users/:id' do
    before { login }
    let(:valid_attributes) { { user: { username: 'saun', password: 'qwerty' } } }

    context 'when User with Admin role updates User Details' do
      before { set_current_user(admin_user) }
      context 'when User updates self details' do
        context 'when the record exists' do
          context 'when the request is valid' do
            before { put "/users/#{admin_user.id}", params: { user: { username: admin_user.username, password: admin_user.password } } }

            it 'updates the record' do
              expect(json['username']).to eq(admin_user.username)
            end

            it 'returns status code 204' do
              expect(response).to have_http_status(200)
            end
          end
          context 'when the request is invalid' do
            before { put "/users/#{admin_user.id}", params: { user: { username: nil, password: 'qwerty' } } }

            it 'returns status code 400' do
              expect(response).to have_http_status(400)
            end

            it 'returns a validation failure message' do
              expect(response.body).to match(/Username can't be blank/)
            end
          end
        end
      end
      context 'when User updates another users details' do
        before { put "/users/#{user_id}", params: valid_attributes }
        it 'returns a validation message' do
          expect(response.body).to match(/Cannot update another User details/)
        end
      end
    end
    context 'when User with member role updates User details' do
      before do
        set_current_user(member_user)
        put "/users/#{user_id}", params: valid_attributes
      end

      it 'returns a validation message' do
        expect(response.body).to match(/Only admin can perform this task/)
      end
    end
  end

  describe 'DELETE /users/:id' do
    before { login }

    context 'When User with Admin roles deletes a User' do
      before { set_current_user(admin_user) }
      context 'When User deletes self Account' do
        before { delete "/users/#{admin_user.id}" }
        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      end
      context 'When User deletes another Users Account' do
        before { delete "/users/#{user_id}" }
        it 'returns a validation message' do
          expect(response.body).to match(/Cannot delete another User Account/)
        end
      end
    end
    context 'When User with Member role deletes a User' do
      before do
        set_current_user(member_user)
        delete "/users/#{user_id}"
      end

      it 'returns a validation message' do
        expect(response.body).to match(/Only admin can perform this task/)
      end
    end
  end

  describe 'POST /Login' do
    let(:valid_attributes) { { user: { username: admin_user.username, password: admin_user.password } } }

    context 'when the credential is valid' do
      before { post '/login', params: valid_attributes }

      it 'logs in successfully' do
        expect(json['user']['username']).to eq(admin_user.username)
      end

      it 'returns a valid token' do
        expect(json['token']).to_not be_empty
      end
    end

    context 'when the credential is invalid' do
      before { post '/login', params: { user: { username: 'tech', password: 'wrongp' } } }

      it 'returns a validation failure message' do
        expect(json['error']).to eq('Invalid username or password')
      end
    end
  end

  describe 'Test webmock stubbing' do
    before do
      stub_request(:get, /api.github.com/).
        with(headers: {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
        to_return(status: 200, body: "stubbed response", headers: {})
    end
    it 'sends api request to github' do
       uri = URI('https://api.github.com/repos/thoughtbot/factory_girl/contributors')
       response = Net::HTTP.get(uri)
       expect(response).to be_an_instance_of(String)
       expect(response).to eq('stubbed response')
    end
  end
end
