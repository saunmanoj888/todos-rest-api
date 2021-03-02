require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  let(:user) { create(:user) }
  let(:admin_user) { create(:user) }
  let(:member_user) { create(:user, role: 'Member') }
  let(:user_id) { user.id }

  describe 'GET /users' do
    before do
      login
      set_current_user(admin_user)
    end

    context 'When permission is not expired' do
      before do
        create(:roles_user, user: admin_user)
        get '/users'
      end
      it 'returns all User details' do
        expect(json).not_to be_empty
        expect(json['users'].size).to eq(1)
        expect(json['users'].first).to have_key('id')
      end
    end

    context 'When permission is expired' do
      before do
        create(:roles_user, user: admin_user, expiry_date: Time.zone.now - 2.days)
        get '/users'
      end
      it 'returns a failure message' do
        expect(response.body).to match(/Cannot view User details/)
      end
    end

    context 'When User has no permissions' do
      before { get '/users' }
      it 'returns a failure message' do
        expect(response.body).to match(/Cannot view User details/)
      end
    end
  end

  describe 'GET /users/:id' do
    before do
      login
      set_current_user(admin_user)
    end

    context 'When permission is not expired' do
      before do
        create(:roles_user, user: admin_user)
        get "/users/#{user_id}"
      end
      it 'returns all User details' do
        expect(json).not_to be_empty
        expect(json['user']['id']).to eq(user_id)
      end
    end

    context 'When permission is expired' do
      before do
        create(:roles_user, user: admin_user, expiry_date: Time.zone.now - 2.days)
        get "/users/#{user_id}"
      end
      it 'returns a failure message' do
        expect(response.body).to match(/Cannot view User details/)
      end
    end

    context 'When User has no permissions' do
      before { get "/users/#{user_id}" }
      it 'returns a failure message' do
        expect(response.body).to match(/Cannot view User details/)
      end
    end
  end

  describe 'POST /users' do
    before { login }
    let(:valid_attributes) {
      { user: { username: 'manoj', password: 'qwerty', role: 'Admin', email: 'test@example.com', first_name: 'toe', last_name: 'sews' } }
    }

    context 'when User with Admin role logs in' do
      before { set_current_user(admin_user) }
      context 'when the request is valid' do
        before { post '/users', params: valid_attributes }

        it 'creates a user' do
          expect(json['user']['username']).to eq('manoj')
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
              expect(json['user']['username']).to eq(admin_user.username)
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

  describe 'POST /Assign Role' do
    before { login }
    context 'When Permission is not expired' do
      context 'When Logged in User can manage users' do
        context 'When Logged in User max role is greater than updating users max role' do
          before do
            set_current_user(admin_user)
            create(:roles_user, user: admin_user)
            post "/users/#{user_id}/assign_role", params: { user: { role_name: 'SuperAdmin', expiry_date: (Time.zone.now + 2.days) } }
          end

          it 'can assign role to other Users' do
            expect(json).not_to be_empty
            expect(json).to have_key('role_id')
          end
        end
        context 'When Logged in User max role is less than updating users max role' do
          before do
            set_current_user(member_user)
            member_user.roles << create(:role, :supervisor)
            create(:roles_user, user: admin_user)
            post "/users/#{admin_user.id}/assign_role", params: { user: { role_name: 'SuperAdmin', expiry_date: (Time.zone.now + 2.days) } }
          end

          it 'returns a failure message' do
            expect(response.body).to match(/Logged in User role level is less than Updating User role level/)
          end
        end
      end

      context 'When Logged in User cannot manage users' do
        before do
          set_current_user(admin_user)
          admin_user.roles << create(:role, :member)
          post "/users/#{user_id}/assign_role", params: { user: { role_name: 'Member', expiry_date: (Time.zone.now + 2.days) } }
        end

        it 'returns a failure message' do
          expect(response.body).to match(/You dont have permission to update User details/)
        end
      end
    end
    context 'When Permission is expired' do
      before do
        set_current_user(admin_user)
        create(:roles_user, user: admin_user, expiry_date: Time.zone.now - 2.days)
        post "/users/#{user_id}/assign_role", params: { user: { role_name: 'SuperAdmin', expiry_date: (Time.zone.now + 2.days) } }
      end

      it 'returns a failure message' do
        expect(response.body).to match(/You dont have permission to update User details/)
      end
    end
  end
end
