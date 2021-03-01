class AddEmailFirstnameLastnameToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :email, :string
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
  end
end
