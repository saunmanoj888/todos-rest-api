class CreateItems < ActiveRecord::Migration[6.1]
  def change
    create_table :items do |t|
      t.string :name
      t.boolean :checked, default: false
      t.references :todo
      t.bigint :creator_id
      t.bigint :assignee_id
      t.timestamps

      t.index :creator_id
      t.index :assignee_id
    end
  end
end
