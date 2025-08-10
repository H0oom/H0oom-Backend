class ChatRoom < ApplicationRecord
  belongs_to :user1, class_name: 'User'
  belongs_to :user2, class_name: 'User'
  has_many :messages, dependent: :destroy
  
  validates :user1_id, presence: true
  validates :user2_id, presence: true
  validate :users_must_be_different
  
  scope :for_user, ->(user_id) {
    where('user1_id = ? OR user2_id = ?', user_id, user_id)
  }
  
  def participants
    [user1, user2]
  end
  
  def other_user(current_user)
    current_user.id == user1_id ? user2 : user1
  end
  
  private
  
  def users_must_be_different
    if user1_id == user2_id
      errors.add(:base, 'You cannot chat with yourself')
    end
  end
end
