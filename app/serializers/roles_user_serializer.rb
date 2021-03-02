class RoleUserSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :role_id, :username, :role_name, :expiry_date

  def username
    object.user.username
  end

  def role_name
    object.role.name
  end
end
