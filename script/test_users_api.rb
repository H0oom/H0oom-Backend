#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'uri'

# API 기본 URL
BASE_URL = 'http://localhost:3000'

puts "=== Hoom Users API 테스트 ==="
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
    
    # 2. 토큰을 사용하여 사용자 목록 조회
    puts "2. 사용자 목록 조회 (인증 필요)"
    puts "GET #{BASE_URL}/api/v1/users"
    puts "Authorization: Bearer #{token[0..20]}..."
    puts
    
    uri = URI("#{BASE_URL}/api/v1/users")
    http = Net::HTTP.new(uri.host, uri.port)
    
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{token}"
    
    response = http.request(request)
    
    puts "Response Status: #{response.code}"
    puts "Response Body: #{response.body}"
    puts
    
    if response.code == '200'
      puts "✅ 사용자 목록 조회 성공!"
      users = JSON.parse(response.body)
      puts "총 #{users.length}명의 사용자:"
      users.each do |user|
        puts "  - ID: #{user['id']}, 이름: #{user['name']}, 상태: #{user['status']}"
      end
    else
      puts "❌ 사용자 목록 조회 실패"
    end
    
    puts
    puts "3. 토큰 없이 사용자 목록 조회 시도 (401 에러 테스트)"
    puts "GET #{BASE_URL}/api/v1/users"
    puts "Authorization: 없음"
    puts
    
    uri = URI("#{BASE_URL}/api/v1/users")
    http = Net::HTTP.new(uri.host, uri.port)
    
    request = Net::HTTP::Get.new(uri)
    # Authorization 헤더 없음
    
    response = http.request(request)
    
    puts "Response Status: #{response.code}"
    puts "Response Body: #{response.body}"
    puts
    
    if response.code == '401'
      puts "✅ 인증 실패 테스트 성공 (예상된 401 에러)"
    else
      puts "❌ 예상과 다른 응답"
    end
    
  else
    puts "❌ 로그인 실패"
  end
rescue => e
  puts "❌ 에러: #{e.message}"
end

puts
puts "=== 테스트 완료 ==="
