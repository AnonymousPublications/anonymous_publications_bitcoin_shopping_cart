class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :header
      t.text :body
      t.string :message_type
      t.string :message_status, :default => "unread"

      t.timestamps
    end
  end
end
