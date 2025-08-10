module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user
    
    def connect
      self.current_user = find_verified_user
    end
    
    private
    
    def find_verified_user
      token = extract_token_from_header
      
      if token.blank?
        reject_unauthorized_connection
        return
      end
      
      payload = JwtService.decode(token)
      
      if payload.nil?
        reject_unauthorized_connection
        return
      end
      
      user = User.find_by(id: payload[0]['user_id'])
      
      if user.nil?
        reject_unauthorized_connection
        return
      end
      
      user
    end
    
    def extract_token_from_header
      # WebSocket 연결에서 토큰 추출
      # 클라이언트에서 연결 시 토큰을 전달해야 함
      request.params[:token] || request.headers['Authorization']&.split(' ')&.last
    end
  end
end
