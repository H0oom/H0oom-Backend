
    class UsersController < ApplicationController
      include JwtAuthenticatable
      skip_before_action :verify_authenticity_token
      
      def index
        users = User.all.map do |user|
          {
            id: user.id,
            name: user.fullname,
            status: user_online_status(user)
          }
        end
        
        render json: users, status: :ok
      end
      
      private
      
      def user_online_status(user)
        user.id == current_user.id ? 'online' : 'offline'
      end
    end
