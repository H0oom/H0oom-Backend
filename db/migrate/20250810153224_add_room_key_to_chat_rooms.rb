class AddRoomKeyToChatRooms < ActiveRecord::Migration[8.0]
  def up
    # First add room_key as nullable
    add_column :chat_rooms, :room_key, :string
    
    # Populate room_key for existing records
    ChatRoom.reset_column_information
    ChatRoom.find_each do |room|
      # Since we can't access the old user1_id and user2_id anymore, we'll generate a unique key
      room.update!(room_key: "room_#{room.id}_#{SecureRandom.hex(4)}")
    end
    
    # Now make room_key NOT NULL and add unique index
    change_column_null :chat_rooms, :room_key, false
    add_index :chat_rooms, :room_key, unique: true
    
    # Remove old columns
    remove_column :chat_rooms, :user1_id, :integer
    remove_column :chat_rooms, :user2_id, :integer
    
    # Remove old indexes
    remove_index :chat_rooms, [:user1_id, :user2_id] if index_exists?(:chat_rooms, [:user1_id, :user2_id])
    remove_index :chat_rooms, [:user2_id, :user1_id] if index_exists?(:chat_rooms, [:user2_id, :user1_id])
  end
  
  def down
    # Add back old columns
    add_column :chat_rooms, :user1_id, :integer
    add_column :chat_rooms, :user2_id, :integer
    
    # Add back old indexes
    add_index :chat_rooms, [:user1_id, :user2_id], unique: true
    add_index :chat_rooms, [:user2_id, :user1_id], unique: true
    
    # Remove new column
    remove_index :chat_rooms, :room_key
    remove_column :chat_rooms, :room_key
  end
end
