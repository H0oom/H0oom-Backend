# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# 테스트용 사용자 데이터 생성
users_data = [
  { fullname: "Dahan Lee", email: "lsmdahan@gmail.com", password: "123456" },
  { fullname: "Sakamoto Park", email: "sakamoto@example.com", password: "123456" },
  { fullname: "John Doe", email: "john@example.com", password: "123456" },
  { fullname: "Jane Smith", email: "jane@example.com", password: "123456" }
]

users_data.each do |user_data|
  User.find_or_create_by!(email: user_data[:email]) do |user|
    user.fullname = user_data[:fullname]
    user.password = user_data[:password]
  end
end

puts "테스트 사용자 데이터가 생성되었습니다."
puts "총 #{User.count}명의 사용자가 있습니다."
