class ChatChannel < ApplicationCable::Channel
  def subscribed
    room_id = params[:room_id]
    
    if room_id.present?
      stream_from "chat_room_#{room_id}"
    else
      reject
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
  
  def send_message(data)
    room_id = params[:room_id]
    message_content = data['message']
    
    # 채팅방 찾기
    chat_room = ChatRoom.find_by(id: room_id)
    return unless chat_room
    
    # 현재 사용자가 채팅방 참가자인지 확인
    user = User.find_by(id: current_user_id)
    return unless user && chat_room.participants.include?(user)
    
    # 메시지 생성
    message = chat_room.messages.create!(
      user: user,
      content: message_content
    )
    
    # WebSocket으로 메시지 브로드캐스트
    ActionCable.server.broadcast "chat_room_#{room_id}", {
      id: message.id,
      user: message.user_name,
      message: message.content,
      created_at: message.created_at.iso8601
    }
  end
  
  private
  
  def current_user_id
    # JWT 토큰에서 사용자 ID 추출
    # 실제 구현에서는 connection에서 사용자 정보를 가져와야 함
    connection.current_user&.id
  end
end
