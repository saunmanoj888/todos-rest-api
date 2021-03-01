class CreateAuthorizations < ActiveRecord::Migration[6.1]
  def change
    create_table :authorizations do |t|
      t.belongs_to :user
      t.belongs_to :role
      t.datetime :expiry_date

      t.timestamps
    end
  end
end
