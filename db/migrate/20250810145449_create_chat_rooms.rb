class CreateChatRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :chat_rooms do |t|
      t.integer :user1_id, null: false
      t.integer :user2_id, null: false
      t.timestamps
    end
    
    add_index :chat_rooms, [:user1_id, :user2_id], unique: true
    add_index :chat_rooms, [:user2_id, :user1_id], unique: true
  end
end
