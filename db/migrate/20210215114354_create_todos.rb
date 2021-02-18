class CreateTodos < ActiveRecord::Migration[6.1]
  def change
    create_table :todos do |t|
      t.string :title
      t.string :status
      t.bigint :creator_id
      t.timestamps

      t.index :creator_id
    end
  end
end
