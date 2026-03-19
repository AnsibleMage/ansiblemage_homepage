# AnsibleMage Homepage

Ruby on Rails 8 기반의 픽셀 아트 테마 개인 블로그 및 포트폴리오 웹사이트입니다. GitHub OAuth 인증, Markdown 블로그, 다크 모드, Kamal 배포를 지원합니다.

## 주요 기능

### 블로그 시스템
- **Markdown 렌더링** -- Redcarpet과 Rouge를 활용한 마크다운 작성 및 구문 강조
- **태그 및 검색** -- 태그별 필터링, Stimulus 컨트롤러 기반 전문 검색
- **좋아요 및 댓글** -- 익명(IP 기반) 및 인증 사용자 좋아요, 댓글 상호작용
- **관리자 패널** -- `/admin/posts`에서 게시글 CRUD 관리

### 인증
- **GitHub OAuth** -- OmniAuth를 통한 GitHub 로그인
- **사용자 프로필** -- GitHub 아바타, 로그인, 표시 이름 동기화

### 디자인
- **픽셀 아트 테마** -- 우주/사이버펑크 컬러 팔레트의 8-bit/16-bit 레트로 감성
- **다크 모드 토글** -- WCAG AA 준수, 시스템 환경 설정 감지, localStorage 유지, FOUC 방지
- **픽셀 마법사 캐릭터** -- CSS 픽셀 아트 아바타와 부유 애니메이션
- **반응형 레이아웃** -- Tailwind CSS v4 기반 모바일 우선 설계

### 인프라
- **Rails 8 Solid Stack** -- Solid Cache, Solid Queue, Solid Cable
- **Kamal 배포** -- Docker 기반 배포, Traefik 프록시, Let's Encrypt SSL
- **PWA 지원** -- Service Worker 및 웹 앱 매니페스트

## 기술 스택

| 구성 요소 | 기술 |
|----------|------|
| 언어 | Ruby 3.3.0 |
| 프레임워크 | Ruby on Rails 8.0.4 |
| 프론트엔드 | Hotwire (Turbo + Stimulus), Importmap |
| 스타일링 | Tailwind CSS v4 |
| 자산 파이프라인 | Propshaft |
| 데이터베이스 | SQLite3 |
| 인증 | OmniAuth (GitHub) |
| 마크다운 | Redcarpet + Rouge |
| 테스트 | RSpec, Capybara, FactoryBot, SimpleCov |
| 배포 | Kamal / Docker |

## 프로젝트 구조

```
ansiblemage_homepage/
├── app/
│   ├── controllers/
│   │   ├── admin/posts_controller.rb
│   │   ├── posts_controller.rb
│   │   ├── comments_controller.rb
│   │   ├── likes_controller.rb
│   │   ├── pages_controller.rb
│   │   └── sessions_controller.rb
│   ├── javascript/controllers/
│   │   ├── dark_mode_controller.js
│   │   ├── search_controller.js
│   │   ├── tag_filter_controller.js
│   │   └── mobile_menu_controller.js
│   ├── models/
│   │   ├── post.rb
│   │   ├── user.rb
│   │   ├── comment.rb
│   │   └── like.rb
│   └── views/
│       ├── pages/       # home, about, projects
│       ├── posts/       # 블로그 목록 및 상세
│       ├── comments/    # Turbo Stream 파셜
│       └── shared/      # 내비게이션 바, 푸터, 픽셀 마법사
├── config/
│   ├── routes.rb
│   ├── deploy.yml       # Kamal 배포 설정
│   └── initializers/
│       └── omniauth.rb
├── db/
│   ├── schema.rb
│   └── migrate/
├── spec/                # RSpec 테스트
│   ├── models/
│   ├── requests/
│   └── system/
└── doc/
    ├── PRD.md
    └── DARK_MODE_IMPLEMENTATION.md
```

## 시작하기

### 필수 조건
- Ruby 3.3.0 이상
- Bundler

### 설치

```bash
git clone https://github.com/AnsibleMage/ansiblemage_homepage.git
cd ansiblemage_homepage
bundle install
bin/rails db:setup
```

### 실행

```bash
bin/dev
```

웹 브라우저에서 `http://localhost:3000`으로 접속하세요.

### 테스트

```bash
bundle exec rspec
```

## 페이지 구성

| 경로 | 설명 |
|------|------|
| `/` | 홈 -- 픽셀 마법사 히어로, 인용구, CTA |
| `/about` | AnsibleMage 소개 |
| `/projects` | 프로젝트 쇼케이스 |
| `/posts` | 블로그 목록 (검색 및 태그 필터) |
| `/posts/:slug` | 블로그 상세 (좋아요, 댓글) |
| `/admin/posts` | 관리자 게시글 관리 |

## 라이선스

이 프로젝트는 [MIT 라이선스](LICENSE)를 따릅니다.
