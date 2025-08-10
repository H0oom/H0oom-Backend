class User < ApplicationRecord
  has_secure_password
  
  # 채팅 관련 관계
  has_many :chat_rooms_as_user1, class_name: 'ChatRoom', foreign_key: 'user1_id'
  has_many :chat_rooms_as_user2, class_name: 'ChatRoom', foreign_key: 'user2_id'
  has_many :messages, dependent: :destroy
  
  validates :fullname, presence: true, length: { minimum: 2, maximum: 50 }
  validates :email, presence: true, 
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  
  before_save :downcase_email
  
  def chat_rooms
    ChatRoom.for_user(id)
  end
  
  private
  
  def downcase_email
    self.email = email.downcase if email.present?
  end
end
