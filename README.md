# Hoom - 채팅 애플리케이션

Hoom은 실시간 채팅 기능을 제공하는 Rails 기반 웹 애플리케이션입니다.

## 🚀 주요 기능

- **사용자 인증**: JWT 기반 회원가입/로그인
- **1:1 채팅**: 사용자 간 개인 채팅방
- **실시간 메시징**: Action Cable을 통한 실시간 통신
- **사용자 관리**: 사용자 프로필 및 목록 조회

## 🛠️ 기술 스택

- **Backend**: Ruby on Rails 8.0
- **Database**: SQLite (개발), PostgreSQL (프로덕션)
- **Authentication**: JWT (JSON Web Token)
- **Real-time**: Action Cable
- **Container**: Docker

## 📋 요구사항

- Ruby 3.3.5+
- Rails 8.0+
- SQLite3 또는 PostgreSQL

## 🚀 설치 및 실행

### 1. 저장소 클론
```bash
git clone <repository-url>
cd Hoom
```

### 2. 의존성 설치
```bash
bundle install
```

### 3. 데이터베이스 설정
```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

### 4. 서버 실행
```bash
bin/rails server
```

애플리케이션은 `http://localhost:3000`에서 실행됩니다.

## 🐳 Docker로 실행

### 1. 이미지 빌드
```bash
docker build -t hoom .
```

### 2. 컨테이너 실행
```bash
docker run -d -p 8080:8080 -e RAILS_MASTER_KEY=<your_master_key> --name hoom hoom
```

Docker 컨테이너는 `http://localhost:8080`에서 실행됩니다.

## 🧪 테스트 실행

### Rails 테스트
```bash
# 전체 테스트
bin/rails test

# 특정 테스트
bin/rails test test/controllers/users_controller_test.rb
```

### API 기능 테스트

#### 1. 종합 테스트 스크립트
```bash
ruby test_all_features.rb
```
- 모든 API 엔드포인트 테스트
- 인증, 사용자 관리, 채팅 기능 종합 테스트
- 상세한 결과 리포트

#### 2. 간단한 테스트 스크립트
```bash
ruby simple_test.rb
```
- 핵심 기능만 빠르게 테스트
- 기본적인 API 동작 확인

#### 3. Rails 콘솔 테스트
```bash
bin/rails console
load 'console_test.rb'
ConsoleTester.run_all_tests
```
- 모델 및 데이터베이스 관계 테스트
- Rails 환경에서 직접 실행

## 📡 API 엔드포인트

### 인증
- `POST /auth/signup` - 사용자 회원가입
- `POST /auth/signin` - 사용자 로그인

### 사용자
- `GET /users` - 사용자 목록 조회 (인증 필요)

### 채팅
- `POST /chat/session` - 채팅방 생성
- `GET /chat/:room_id/messages` - 메시지 조회

## 🗄️ 데이터베이스 구조

### 주요 테이블
- **users**: 사용자 정보
- **chat_rooms**: 채팅방 정보 (room_key 기반)
- **chat_room_users**: 채팅방-사용자 다대다 관계
- **messages**: 채팅 메시지

### 관계
- User ↔ ChatRoom (many-to-many through ChatRoomUser)
- ChatRoom ↔ Message (one-to-many)
- User ↔ Message (one-to-many)

## 🔧 개발 환경 설정

### 환경 변수
```bash
# .env 파일 생성
RAILS_ENV=development
RAILS_MASTER_KEY=your_master_key_here
```

### 데이터베이스 설정
`config/database.yml`에서 데이터베이스 연결 정보를 설정하세요.

## 🚀 배포

### Kamal을 사용한 배포
```bash
bin/kamal deploy
```

### 수동 배포
```bash
# 프로덕션 빌드
RAILS_ENV=production bin/rails assets:precompile

# 서버 실행
RAILS_ENV=production bin/rails server
```

## 📝 라이센스

이 프로젝트는 MIT 라이센스 하에 배포됩니다.

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📞 문의

프로젝트에 대한 문의사항이 있으시면 이슈를 생성해주세요.
