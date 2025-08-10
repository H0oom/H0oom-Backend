class Message < ApplicationRecord
  belongs_to :user
  belongs_to :chat_room
  
  validates :content, presence: true, length: { maximum: 1000 }
  validates :user_id, presence: true
  validates :chat_room_id, presence: true
  
  scope :ordered, -> { order(created_at: :asc) }
  
  def user_name
    user.fullname
  end
end
