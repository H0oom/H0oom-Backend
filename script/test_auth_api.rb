#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'uri'

# API 기본 URL
BASE_URL = 'http://localhost:3000'

# 테스트 사용자 데이터
test_user = {
  user: {
    fullname: "Dahan Lee",
    email: "lsmdahan@gmail.com",
    password: "123456"
  }
}

puts "=== Hoom Auth API 테스트 ==="
puts

# 1. 회원가입 테스트
puts "1. 회원가입 테스트"
puts "POST #{BASE_URL}/api/v1/auth/signup"
puts "Request: #{test_user.to_json}"
puts

begin
  uri = URI("#{BASE_URL}/api/v1/auth/signup")
  http = Net::HTTP.new(uri.host, uri.port)
  
  request = Net::HTTP::Post.new(uri)
  request['Content-Type'] = 'application/json'
  request.body = test_user.to_json
  
  response = http.request(request)
  
  puts "Response Status: #{response.code}"
  puts "Response Body: #{response.body}"
  puts
  
  if response.code == '201'
    puts "✅ 회원가입 성공!"
    user_data = JSON.parse(response.body)
    puts "사용자 ID: #{user_data['id']}"
    puts "토큰: #{user_data['token'][0..20]}..."
  else
    puts "❌ 회원가입 실패"
  end
rescue => e
  puts "❌ 에러: #{e.message}"
end

puts
puts "2. 로그인 테스트"
puts "POST #{BASE_URL}/api/v1/auth/signin"
puts "Request: #{test_user[:user].slice(:email, :password).to_json}"
puts

begin
  uri = URI("#{BASE_URL}/api/v1/auth/signin")
  http = Net::HTTP.new(uri.host, uri.port)
  
  request = Net::HTTP::Post.new(uri)
  request['Content-Type'] = 'application/json'
  request.body = { user: test_user[:user].slice(:email, :password) }.to_json
  
  response = http.request(request)
  
  puts "Response Status: #{response.code}"
  puts "Response Body: #{response.body}"
  puts
  
  if response.code == '200'
    puts "✅ 로그인 성공!"
    user_data = JSON.parse(response.body)
    puts "사용자 ID: #{user_data['id']}"
    puts "토큰: #{user_data['token'][0..20]}..."
  else
    puts "❌ 로그인 실패"
  end
rescue => e
  puts "❌ 에러: #{e.message}"
end

puts
puts "=== 테스트 완료 ==="
