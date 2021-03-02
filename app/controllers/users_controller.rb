class UsersController < ApplicationController
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
    expiry_date = params.dig(:user, :authorizations, :expiry_date)

    authorization = @user.authorizations.find_or_initialize_by(role: @role)
    authorization.expiry_date = expiry_date if params.dig(:user, :authorizations).has_key?(:expiry_date)
    if authorization.save
      json_response(authorization)
    else
      json_response({ message: authorization.errors.full_messages }, :bad_request)
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :username, :password, :role, :email, :first_name, :last_name, authorizations_attributes: [:expiry_date]
    )
  end

  def set_user
    @user = User.find(params[:id])
  end

  def verify_read_permissions
    return if current_user&.can_read?

    render json: { message: 'Cannot view User details' }, status: :unauthorized
  end

  def find_role
    @role = Role.find_by(name: params[:role_name])
  end

  def verify_manage_permissions
    return if current_user&.can_manage?

    render json: { message: 'You dont have permission to update User details' }, status: :unauthorized
  end

  def verify_max_role_level
    return if current_user.max_role_level > @user.max_role_level

    render json: { message: 'Logged in User role level is less than Updating User role level' }, status: :unauthorized
  end
end
