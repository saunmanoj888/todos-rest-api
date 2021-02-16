class CreateItems < ActiveRecord::Migration[6.1]
  def change
    create_table :items do |t|
      t.string :name
      t.boolean :checked, default: false
      t.string :added_by
      t.references :todo
      t.references :user
      t.timestamps
    end
  end
end
