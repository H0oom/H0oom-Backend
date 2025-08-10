#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'uri'

# API 기본 URL
BASE_URL = 'http://localhost:3000'

puts "=== Hoom Chat API 테스트 ==="
puts

# 1. 먼저 로그인하여 토큰 획득
puts "1. 로그인하여 토큰 획득"
puts "POST #{BASE_URL}/api/v1/auth/signin"
puts

login_data = {
  user: {
    email: "lsmdahan@gmail.com",
    password: "123456"
  }
}

begin
  uri = URI("#{BASE_URL}/api/v1/auth/signin")
  http = Net::HTTP.new(uri.host, uri.port)
  
  request = Net::HTTP::Post.new(uri)
  request['Content-Type'] = 'application/json'
  request.body = login_data.to_json
  
  response = http.request(request)
  
  puts "Response Status: #{response.code}"
  puts "Response Body: #{response.body}"
  puts
  
  if response.code == '200'
    puts "✅ 로그인 성공!"
    user_data = JSON.parse(response.body)
    token = user_data['token']
    puts "토큰: #{token[0..20]}..."
    puts
    
    # 2. 채팅방 생성
    puts "2. 채팅방 생성 (Sakamoto Park와)"
    puts "POST #{BASE_URL}/api/v1/chat/session"
    puts
    
    chat_data = {
      chat: {
        target_user_id: 2  # Sakamoto Park
      }
    }
    
    uri = URI("#{BASE_URL}/api/v1/chat/session")
    http = Net::HTTP.new(uri.host, uri.port)
    
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['Authorization'] = "Bearer #{token}"
    request.body = chat_data.to_json
    
    response = http.request(request)
    
    puts "Response Status: #{response.code}"
    puts "Response Body: #{response.body}"
    puts
    
    if response.code == '200' || response.code == '201'
      puts "✅ 채팅방 생성/조회 성공!"
      chat_data = JSON.parse(response.body)
      room_id = chat_data['room_id']
      puts "채팅방 ID: #{room_id}"
      puts "참가자: #{chat_data['participants'].map { |p| p['name'] }.join(', ')}"
      puts
      
      # 3. 채팅방 메시지 조회
      puts "3. 채팅방 메시지 조회"
      puts "GET #{BASE_URL}/api/v1/chat/#{room_id}/messages"
      puts
      
      uri = URI("#{BASE_URL}/api/v1/chat/#{room_id}/messages")
      http = Net::HTTP.new(uri.host, uri.port)
      
      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = "Bearer #{token}"
      
      response = http.request(request)
      
      puts "Response Status: #{response.code}"
      puts "Response Body: #{response.body}"
      puts
      
      if response.code == '200'
        puts "✅ 메시지 조회 성공!"
        messages = JSON.parse(response.body)
        puts "총 #{messages.length}개의 메시지"
        messages.each do |msg|
          puts "  - #{msg['user']}: #{msg['message']} (#{msg['created_at']})"
        end
      else
        puts "❌ 메시지 조회 실패"
      end
      
      puts
      puts "4. 존재하지 않는 사용자와 채팅방 생성 시도 (404 에러 테스트)"
      puts "POST #{BASE_URL}/api/v1/chat/session"
      puts
      
      chat_data = {
        chat: {
          target_user_id: 999  # 존재하지 않는 사용자
        }
      }
      
      uri = URI("#{BASE_URL}/api/v1/chat/session")
      http = Net::HTTP.new(uri.host, uri.port)
      
      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request['Authorization'] = "Bearer #{token}"
      request.body = chat_data.to_json
      
      response = http.request(request)
      
      puts "Response Status: #{response.code}"
      puts "Response Body: #{response.body}"
      puts
      
      if response.code == '404'
        puts "✅ 404 에러 테스트 성공 (예상된 에러)"
      else
        puts "❌ 예상과 다른 응답"
      end
      
    else
      puts "❌ 채팅방 생성 실패"
    end
    
  else
    puts "❌ 로그인 실패"
  end
rescue => e
  puts "❌ 에러: #{e.message}"
end

puts
puts "=== 테스트 완료 ==="
puts
puts "WebSocket 테스트는 별도로 진행해야 합니다:"
puts "1. 서버 실행: rails server -p 3000"
puts "2. WebSocket 클라이언트로 연결"
puts "3. 채널 구독: {\"command\":\"subscribe\",\"identifier\":\"{\\\"channel\\\":\\\"ChatChannel\\\",\\\"room_id\\\":#{room_id}}\"}"
puts "4. 메시지 전송: {\"command\":\"message\",\"identifier\":\"{\\\"channel\\\":\\\"ChatChannel\\\",\\\"room_id\\\":#{room_id}}\",\"data\":\"{\\\"action\\\":\\\"send_message\\\",\\\"message\\\":\\\"안녕하세요!\\\"}\"}"
