
    class ChatController < ApplicationController
      include JwtAuthenticatable
      skip_before_action :verify_authenticity_token
      
      # 채팅방 생성 또는 기존 방 반환
      def create_session
        target_user = User.find_by(id: chat_params[:target_user_id])
        
        unless target_user
          render json: { error: 'User not found' }, status: :not_found
          return
        end
        
        # 자기 자신과는 채팅할 수 없음
        if target_user.id == current_user.id
          render json: { error: 'You cannot chat with yourself' }, status: :bad_request
          return
        end
        
        # 기존 채팅방이 있는지 확인
        chat_room = ChatRoom.for_user(current_user.id)
                           .for_user(target_user.id)
                           .first
        
        if chat_room.nil?
          # 새 채팅방 생성
          chat_room = ChatRoom.create!(
            user1_id: [current_user.id, target_user.id].min,
            user2_id: [current_user.id, target_user.id].max
          )
          status = :created
        else
          status = :ok
        end
        
        render json: {
          room_id: chat_room.id,
          participants: chat_room.participants.map do |user|
            {
              id: user.id,
              name: user.fullname
            }
          end
        }, status: status
      end
      
      # 채팅방 메시지 조회
      def messages
        chat_room = ChatRoom.find_by(id: params[:room_id])
        
        unless chat_room
          render json: { error: 'Chat room not found' }, status: :not_found
          return
        end
        
        # 현재 사용자가 해당 채팅방의 참가자인지 확인
        unless chat_room.participants.include?(current_user)
          render json: { error: 'You do not have permission to access this chat room' }, status: :forbidden
          return
        end
        
        messages = chat_room.messages.ordered.map do |message|
          {
            id: message.id,
            user: message.user_name,
            message: message.content,
            created_at: message.created_at.iso8601
          }
        end
        
        render json: messages, status: :ok
      end
      
      private
      
      def chat_params
        params.require(:chat).permit(:target_user_id)
      end
    end