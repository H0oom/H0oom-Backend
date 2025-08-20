
    class AuthController < ApplicationController
      include JwtAuthenticatable
      skip_before_action :authenticate_user!, only: [:signup, :signin]
      skip_before_action :verify_authenticity_token, only: [:signup, :signin]
      def signup
        user = User.new(user_params)

        if user.save
          token = JwtService.generate_token(user)
          render json: {
            id: user.id,
            fullname: user.fullname,
            email: user.email,
            token: token
          }, status: :created
        else
          if user.errors[:email].include?('has already been taken')
            render json: { error: '이미 가입된 이메일입니다.' }, status: :conflict
          else
            render json: { error: user.errors.full_messages.join(', ') }, status: :bad_request
          end
        end
      end

      def signin
        user = User.find_by(email: login_params[:email].downcase)

        if user&.authenticate(login_params[:password])
          token = JwtService.generate_token(user)
          render json: {
            id: user.id,
            fullname: user.fullname,
            email: user.email,
            token: token
          }, status: :ok
        elsif user.nil?
          render json: { error: 'User not found' }, status: :not_found
        else
          render json: { error: 'Wrong password' }, status: :bad_request
        end
      end

      private

      def user_params
        if params[:user].present?
          params.require(:user).permit(:fullname, :email, :password)
        else
          params.permit(:fullname, :email, :password)
        end
      end

      def login_params
        if params[:user].present?
          params.require(:user).permit(:email, :password)
        else
          params.permit(:email, :password)
        end
      end
    end