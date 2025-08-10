class ChatRoom < ApplicationRecord
  has_many :chat_room_users, dependent: :destroy
  has_many :users, through: :chat_room_users
  has_many :messages, dependent: :destroy
  
  validates :room_key, presence: true, uniqueness: true
  
  scope :for_user, ->(user_id) {
    joins(:chat_room_users).where(chat_room_users: { user_id: user_id })
  }
  
  def participants
    users
  end
  
  def other_user(current_user)
    users.where.not(id: current_user.id).first
  end
  
  def self.find_or_create_for_users(user1, user2)
    # Generate a unique room key for the two users
    user_ids = [user1.id, user2.id].sort
    room_key = "room_#{user_ids.join('_')}"
    
    find_or_create_by(room_key: room_key) do |room|
      room.users = [user1, user2]
    end
  end
end
