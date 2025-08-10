# Hoom API 문서

## 기본 정보
- **Base URL**: `http://localhost:3000`
- **API Version**: v1
- **Content-Type**: `application/json`

## 인증

대부분의 API는 JWT 토큰 인증이 필요합니다.

**Authorization Header**: `Bearer {token}`

## 엔드포인트

### 1. 회원가입 (Sign Up)

**POST** `/api/v1/auth/signup`

#### Request Body
```json
{
  "user": {
    "fullname": "Dahan Lee",
    "email": "lsmdahan@gmail.com",
    "password": "123456"
  }
}
```

#### Response

**201 Created** - 성공적인 회원가입
```json
{
  "id": 1,
  "fullname": "Dahan Lee",
  "email": "lsmdahan@gmail.com",
  "token": "jwt_token_string"
}
```

**400 Bad Request** - 잘못 입력된 경우
```json
{
  "error": "Fullname is too short (minimum is 2 characters)"
}
```

**409 Conflict** - 이미 가입된 이메일
```json
{
  "error": "이미 가입된 이메일입니다."
}
```

---

### 2. 로그인 (Sign In)

**POST** `/api/v1/auth/signin`

#### Request Body
```json
{
  "user": {
    "email": "lsmdahan@gmail.com",
    "password": "123456"
  }
}
```

#### Response

**200 Success** - 정상적인 로그인
```json
{
  "id": 1,
  "fullname": "Dahan Lee",
  "email": "lsmdahan@gmail.com",
  "token": "jwt_token_string"
}
```

**400 Bad Request** - 잘못된 비밀번호
```json
{
  "error": "Wrong password"
}
```

**404 Not Found** - 존재하지 않는 유저
```json
{
  "error": "User not found"
}
```

---

### 3. 사용자 목록 조회

**GET** `/api/v1/users`

**인증 필요**: `Authorization: Bearer {token}`

#### Response

**200 Success** - 사용자 목록
```json
[
  { "id": 1, "name": "Dahan Lee", "status": "online" },
  { "id": 2, "name": "Sakamoto Park", "status": "offline" },
  { "id": 3, "name": "John Doe", "status": "offline" },
  { "id": 4, "name": "Jane Smith", "status": "offline" }
]
```

**401 Unauthorized** - 토큰 없음/만료
```json
{
  "error": "토큰이 필요합니다."
}
```

---

### 4. 채팅방 생성/조회

**POST** `/api/v1/chat/session`

**인증 필요**: `Authorization: Bearer {token}`

#### Request Body
```json
{
  "chat": {
    "target_user_id": 5
  }
}
```

#### Response

**201 Created** - 새 채팅방 생성
**200 OK** - 기존 채팅방 반환
```json
{
  "room_id": 12,
  "participants": [
    { "id": 3, "name": "Alice" },
    { "id": 5, "name": "Bob" }
  ]
}
```

**400 Bad Request** - 자기 자신과 채팅 시도
```json
{
  "error": "자기 자신과는 채팅할 수 없습니다."
}
```

**404 Not Found** - 해당 유저가 존재하지 않음
```json
{
  "error": "해당 유저가 존재하지 않습니다."
}
```

**401 Unauthorized** - 인증 실패
```json
{
  "error": "토큰이 필요합니다."
}
```

---

### 5. 채팅방 메시지 조회

**GET** `/api/v1/chat/:room_id/messages`

**인증 필요**: `Authorization: Bearer {token}`

#### Response

**200 Success** - 메시지 목록
```json
[
  { "id": 101, "user": "Alice", "message": "안녕", "created_at": "2025-08-10T12:00:00Z" },
  { "id": 102, "user": "Bob", "message": "하이", "created_at": "2025-08-10T12:01:00Z" }
]
```

**404 Not Found** - 채팅방을 찾을 수 없음
```json
{
  "error": "채팅방을 찾을 수 없습니다."
}
```

**403 Forbidden** - 채팅방 접근 권한 없음
```json
{
  "error": "해당 채팅방에 접근할 권한이 없습니다."
}
```

**401 Unauthorized** - 인증 실패
```json
{
  "error": "토큰이 필요합니다."
}
```

---

## WebSocket 채널

### 채널 이름
`chat_room_<room_id>`

### 연결 방법
```javascript
// ActionCable 연결
const cable = ActionCable.createConsumer('ws://localhost:3000/cable?token=YOUR_JWT_TOKEN');

// 채팅방 구독
const subscription = cable.subscriptions.create(
  { channel: "ChatChannel", room_id: 12 },
  {
    received(data) {
      console.log('새 메시지:', data);
    }
  }
);
```

### 구독
```json
{
  "command": "subscribe",
  "identifier": "{\"channel\":\"ChatChannel\",\"room_id\":12}"
}
```

### 메시지 전송
```json
{
  "command": "message",
  "identifier": "{\"channel\":\"ChatChannel\",\"room_id\":12}",
  "data": "{\"action\":\"send_message\",\"message\":\"잘 지내?\"}"
}
```

---

## JWT 토큰

- **알고리즘**: HS256
- **만료 시간**: 24시간
- **페이로드**: `user_id`, `email`, `exp`

## 테스트 방법

### 1. 서버 실행
```bash
cd Hoom
rails server -p 3000
```

### 2. 테스트 데이터 생성
```bash
cd Hoom
rails db:seed
```

### 3. API 테스트

#### 회원가입
```bash
curl -X POST http://localhost:3000/api/v1/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "fullname": "Dahan Lee",
      "email": "lsmdahan@gmail.com",
      "password": "123456"
    }
  }'
```

#### 로그인
```bash
curl -X POST http://localhost:3000/api/v1/auth/signin \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "lsmdahan@gmail.com",
      "password": "123456"
    }
  }'
```

#### 사용자 목록 조회 (인증 필요)
```bash
curl -X GET http://localhost:3000/api/v1/users \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

#### 채팅방 생성
```bash
curl -X POST http://localhost:3000/api/v1/chat/session \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "chat": {
      "target_user_id": 2
    }
  }'
```

#### 채팅방 메시지 조회
```bash
curl -X GET http://localhost:3000/api/v1/chat/12/messages \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### 4. 테스트 스크립트 실행

#### 인증 API 테스트
```bash
cd Hoom
ruby test_auth_api.rb
```

#### 사용자 목록 API 테스트
```bash
cd Hoom
ruby test_users_api.rb
```

#### 채팅 API 테스트
```bash
cd Hoom
ruby test_chat_api.rb
```

## 에러 코드

| Status Code | 설명 |
|-------------|------|
| 200 | 성공 (로그인, 사용자 목록, 메시지 조회, 기존 채팅방) |
| 201 | 생성됨 (회원가입, 새 채팅방) |
| 400 | 잘못된 요청 (자기 자신과 채팅 시도) |
| 401 | 인증 실패 (토큰 없음/만료) |
| 403 | 권한 없음 (채팅방 접근 권한) |
| 404 | 리소스를 찾을 수 없음 (사용자, 채팅방) |
| 409 | 충돌 (중복) |

## 주의사항

1. 이메일은 자동으로 소문자로 변환됩니다
2. 비밀번호는 최소 6자 이상이어야 합니다
3. JWT 토큰은 24시간 후 만료됩니다
4. 모든 API 요청은 JSON 형식이어야 합니다
5. 사용자 목록과 채팅 API는 JWT 토큰 인증이 필요합니다
6. 온라인 상태는 현재 로그인한 사용자만 'online'으로 표시됩니다
7. 채팅방은 두 사용자 간에 하나만 생성됩니다 (중복 방지)
8. WebSocket 연결 시 JWT 토큰을 쿼리 파라미터로 전달해야 합니다
9. 메시지는 최대 1000자까지 입력 가능합니다
10. 채팅방 참가자만 메시지를 조회할 수 있습니다
