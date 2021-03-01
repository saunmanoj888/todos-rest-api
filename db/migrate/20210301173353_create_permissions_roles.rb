class CreatePermissionsRoles < ActiveRecord::Migration[6.1]
  def change
    create_table :permissions_roles, id: false do |t|
      t.belongs_to :role
      t.belongs_to :permission
    end

    add_index :permissions_roles, [:permission_id, :role_id], unique: true
  end
end
