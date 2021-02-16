class CreateTodos < ActiveRecord::Migration[6.1]
  def change
    create_table :todos do |t|
      t.string :title
      t.string :status
      t.string :created_by
      t.references :user
      t.timestamps
    end
  end
end
