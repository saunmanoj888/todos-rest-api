class UsersController < ApplicationController
  include UserFilter

  before_action :set_user, only: %i[show update destroy assign_role]
  before_action :authorized, except: %i[login]
  before_action :authorize_user, only: %i[create update destroy]
  before_action :verify_read_permissions, only: %i[index show]
  before_action :find_role, only: :assign_role
  before_action :verify_manage_permissions, only: :assign_role
  before_action :verify_max_role_level, only: :assign_role

  def index
    json_response(User.all)
  end

  def show
    json_response(@user)
  end

  def create
    @user = User.new(user_params)
    if @user.save
      json_response(@user, :created)
    else
      json_response({ message: @user.errors.full_messages }, :bad_request)
    end
  end

  def update
    return json_response({ error: 'Cannot update another User details' }, :unauthorized) if @user != current_user

    if @user.update(user_params)
      json_response(@user)
    else
      json_response({ message: @user.errors.full_messages }, :bad_request)
    end
  end

  def destroy
    return json_response({ error: 'Cannot delete another User Account' }, :unauthorized) if @user != current_user

    if @user.destroy
      json_response({ message: 'User destroyed successfully' })
    else
      json_response({ message: @user.errors.full_messages }, :bad_request)
    end
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

  def assign_role
    expiry_date = params[:user][:expiry_date]

    authorization = @user.roles_users.find_or_initialize_by(role: @role)
    authorization.expiry_date = expiry_date if params[:user].has_key?(:expiry_date)
    if authorization.save
      json_response(authorization)
    else
      json_response({ message: authorization.errors.full_messages }, :bad_request)
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :password, :role, :email, :first_name, :last_name)
  end

  def set_user
    @user = User.find(params[:id])
  end

  def find_role
    @role = Role.find_by!(name: params[:user][:role_name])
  end
end
