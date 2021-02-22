class UsersController < ApplicationController
  before_action :set_user, only: %i[show update destroy]
  before_action :authorized, except: %i[login]
  before_action :authorize_user, only: %i[show create update destroy]

  def index
    @users = current_user.admin? ? User.all : [current_user]
    json_response(@users)
  end

  def show
    json_response(@user)
  end

  def create
    @user = User.create!(user_params)
    json_response(@user, :created)
  end

  def update
    return json_response({ error: 'Cannot update another User details' }, :unauthorized) unless @user == current_user

    @user.update!(user_params)
    json_response(@user)
  end

  def destroy
    return json_response({ error: 'Cannot delete another User Account' }, :unauthorized) unless @user == current_user

    @user.destroy
    head :no_content
  end

  def login
    @user = User.find_by(username: params[:user][:username])

    if @user&.authenticate(params[:user][:password])
      token = encode_token({ user_id: @user.id })
      render json: { user: @user, token: token }
    else
      render json: { error: 'Invalid username or password' }
    end
  end

  def auto_login
    render json: @user
  end

  private

  def user_params
    params.require(:user).permit(:username, :password, :role)
  end

  def set_user
    @user = User.find(params[:id])
  end
end
