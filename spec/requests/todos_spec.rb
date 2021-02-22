require 'rails_helper'

RSpec.describe 'Todos API', type: :request do
  let(:admin_user) { create(:user) }
  let(:member_user) { create(:user, role: 'Member') }
  let!(:todos) { create_list(:todo, 10) }
  let(:todo) { todos.first }
  let(:todo_id) { todo.id }
  let(:todo_created_by_admin) { create(:todo, creator: admin_user) }

  describe 'GET /todos' do
    before { login }
    before { get '/todos' }

    context 'When User is Admin' do
      before { set_current_user(admin_user) }
      before { todo_created_by_admin }
      before { get '/todos' }

      it 'returns all todos belonging to the User only' do
        expect(json).not_to be_empty
        expect(json.size).to eq(1)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'When User is Member' do
      before { set_current_user(member_user) }
      before { get '/todos' }

      it 'returns a validation message' do
        expect(response.body).to match(/Only admin can perform this task/)
      end
    end
  end

  describe 'GET /todos/:id' do
    before { login }

    context 'When User is Admin' do
      before { set_current_user(admin_user) }
      context 'When User searches Todo created by him/her self' do
        before { get "/todos/#{todo_created_by_admin.id}" }
        context 'when the record exists' do
          it 'returns the todo' do
            expect(json).not_to be_empty
            expect(json['id']).to eq(todo_created_by_admin.id)
          end

          it 'returns status code 200' do
            expect(response).to have_http_status(200)
          end
        end

        context 'when the record does not exist' do
          before { get '/todos/100' }

          it 'returns status code 401' do
            expect(response).to have_http_status(401)
          end

          it 'returns a not found message' do
            expect(response.body).to match(/Couldn't find Todo/)
          end
        end
      end
      context 'When User searched Todo created by some other User' do
        before { get "/todos/#{todo_id}" }
        it 'returns a validation message' do
          expect(response.body).to match(/Only Todo creator can perform this task/)
        end
      end
    end
    context 'When User is Member' do
      before { set_current_user(member_user) }
      before { get "/todos/#{todo_id}" }

      it 'returns a validation message' do
        expect(response.body).to match(/Only admin can perform this task/)
      end
    end
  end

  describe 'POST /todos' do
    before { login }

    context 'when user is Admin' do
      before { set_current_user(admin_user) }
      let(:valid_attributes) { { todo: { title: 'Learn Elm', creator_id: admin_user.id, status: 'draft' } } }
      context 'when the request is valid' do
        before { post '/todos', params: valid_attributes }

        it 'creates a todo' do
          expect(json['title']).to eq('Learn Elm')
        end

        it 'returns status code 201' do
          expect(response).to have_http_status(201)
        end
      end

      context 'when the request is invalid' do
        before { post '/todos', params: { todo: { title: nil } } }

        it 'returns status code 400' do
          expect(response).to have_http_status(400)
        end

        it 'returns a validation failure message' do
          expect(response.body).to match(/Validation failed: Title can't be blank/)
        end
      end
    end
    context 'when user is Member' do
      before { set_current_user(member_user) }
      before { post '/todos', params: { todo: { title: 'Foobar' } } }
      it 'return a validation failure message' do
        expect(response.body).to match(/Only admin can perform this task/)
      end
    end
  end

  describe 'PUT /todos/:id' do
    before { login }
    let(:valid_attributes) { { todo: { title: 'Shopping' } } }

    context 'when user is admin' do
      context 'when todo belongs to the user' do
        before { set_current_user(todo.creator) }

        context 'when the record exists' do
          context 'when record is valid' do
            before { put "/todos/#{todo_id}", params: valid_attributes }
            it 'updates the record' do
              expect(json['title']).to eq('Shopping')
            end

            it 'returns status code 200' do
              expect(response).to have_http_status(200)
            end
          end
          context 'when record is invalid' do
            before { put "/todos/#{todo_id}", params: { todo: { title: nil } } }
            it 'returns a validation failure message' do
              expect(response.body).to match(/Validation failed: Title can't be blank/)
            end
          end
        end
      end
      context 'when todo does not belongs to user' do
        before { set_current_user(admin_user) }
        before { put "/todos/#{todo_id}", params: valid_attributes }
        it 'returns a validation failure message' do
          expect(response.body).to match(/Only Todo creator can perform this task/)
        end
      end
    end
    context 'when user is Member' do
      before{ set_current_user(member_user) }
      before { put "/todos/#{todo_id}", params: valid_attributes }
      it 'returns a validation failure message' do
        expect(response.body).to match(/Only admin can perform this task/)
      end
    end
  end

  describe 'DELETE /todos/:id' do

    before { login }

    context 'when user is admin' do

      context 'when todo belongs to user' do

        before { set_current_user(todo.creator) }
        before { delete "/todos/#{todo_id}" }

        it 'returns status code 204' do
          expect(response).to have_http_status(204)
        end
      end

      context 'when todo does not belongs to user' do

        before { set_current_user(admin_user) }
        before { delete "/todos/#{todo_id}" }

        it 'returns a validation failure message' do
          expect(response.body).to match(/Only Todo creator can perform this task/)
        end

      end

    end

    context 'when user is Member' do

      before{ set_current_user(member_user) }
      before { delete "/todos/#{todo_id}" }

      it 'returns a validation failure message' do
        expect(response.body).to match(/Only admin can perform this task/)
      end

    end
  end
end
