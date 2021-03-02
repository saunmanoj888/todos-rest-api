module UserFilter
  extend ActiveSupport::Concern

  included do
    def verify_read_permissions
      return if current_user&.can_access_permission?('can_read_users') || current_user&.can_access_permission?('can_manage_users')

      render json: { message: 'Cannot view User details' }, status: :unauthorized
    end

    def verify_manage_permissions
      return if current_user&.can_access_permission?('can_manage_users')

      render json: { message: 'You dont have permission to update User details' }, status: :unauthorized
      end

    def verify_max_role_level
      return if current_user.max_role_level > @user.max_role_level

      render json: { message: 'Logged in User role level is less than Updating User role level' }, status: :unauthorized
    end
  end
end
