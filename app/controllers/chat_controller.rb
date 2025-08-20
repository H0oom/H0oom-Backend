
    class ChatController < ApplicationController
      include JwtAuthenticatable
      skip_before_action :verify_authenticity_token
      
      def create_session
        target_user = User.find_by(id: chat_params[:target_user_id])
        
        unless target_user
          render json: { error: 'User not found' }, status: :not_found
          return
        end
        
        if target_user.id == current_user.id
          render json: { error: 'You cannot chat with yourself' }, status: :bad_request
          return
        end
        
        chat_room = ChatRoom.for_user(current_user.id)
                           .for_user(target_user.id)
                           .first
        
        if chat_room.nil?
          chat_room = ChatRoom.find_or_create_for_users(current_user, target_user)
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
      
      def show
        chat_room = ChatRoom.find_by(id: params[:room_id])
        
        unless chat_room
          render json: { error: 'Chat room not found' }, status: :not_found
          return
        end
        
        unless chat_room.participants.include?(current_user)
          render json: { error: 'You do not have permission to access this chat room' }, status: :forbidden
          return
        end
        
        render json: {
          room_id: chat_room.id,
          room_key: chat_room.room_key,
          participants: chat_room.participants.map do |user|
            {
              id: user.id,
              name: user.fullname
            }
          end,
          created_at: chat_room.created_at.iso8601
        }, status: :ok
      end

      def messages
        chat_room = ChatRoom.find_by(id: params[:room_id])
        
        unless chat_room
          render json: { error: 'Chat room not found' }, status: :not_found
          return
        end
        

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