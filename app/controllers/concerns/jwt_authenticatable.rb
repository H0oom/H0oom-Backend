module JwtAuthenticatable
  extend ActiveSupport::Concern
  
  included do
    before_action :authenticate_user!
  end
  
  private
  
  def authenticate_user!
    token = extract_token_from_header
    
    if token.blank?
      render json: { error: '토큰이 필요합니다.' }, status: :unauthorized
      return
    end
    
    payload = JwtService.decode(token)
    
    if payload.nil?
      render json: { error: '유효하지 않은 토큰입니다.' }, status: :unauthorized
      return
    end
    
    @current_user = User.find_by(id: payload[0]['user_id'])
    
    if @current_user.nil?
      render json: { error: '사용자를 찾을 수 없습니다.' }, status: :unauthorized
      return
    end
  end
  
  def extract_token_from_header
    auth_header = request.headers['Authorization']
    return nil if auth_header.blank?
    auth_header.split(' ').last
  end
  
  def current_user
    @current_user
  end
end
