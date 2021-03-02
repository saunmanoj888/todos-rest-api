class CreateRolesUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :roles_users do |t|
      t.belongs_to :user
      t.belongs_to :role
      t.datetime :expiry_date

      t.timestamps
    end
  end
end
