class CreateStories < ActiveRecord::Migration
  def change
    create_table :stories do |t|
      t.string :date
      t.string :header
      t.text :body
      t.string :img
      t.string :author

      t.timestamps
    end
  end
end
