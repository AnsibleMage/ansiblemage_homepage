# TaskPlan: AnsibleMage Homepage

> **Project**: AnsibleMage Personal Homepage
> **PRD**: [PRD.md](./PRD.md)
> **Created**: 2026-02-01
> **Status**: 진행 중

---

## 마일스톤 개요

| ID | 마일스톤 | 설명 | Sprint |
|----|----------|------|--------|
| M1 | 기본 인프라 | Rails 생성, 도트 레이아웃, 홈/About | 1 |
| M2 | 블로그 기능 | Post 모델, 목록/상세, 관리자 CRUD | 2 |
| M3 | 상호작용 | 좋아요, GitHub OAuth, 댓글 | 3 |
| M4 | 완성 | Projects, 애니메이션, 배포 | 4 |

---

## Sprint 1: 기본 인프라 (M1)

### T1.1: Rails 8 프로젝트 생성

**우선순위**: P0
**의존성**: 없음

**설명**:
Rails 8 프로젝트를 생성하고 기본 설정을 완료합니다.

**수용 기준**:
- [ ] `rails new ansiblemage_homepage --css=tailwind --skip-jbuilder`
- [ ] RSpec 설정
- [ ] Git 초기화

**예상 파일**:
- `ansiblemage_homepage/` (전체 프로젝트)

---

### T1.2: 도트 스타일 레이아웃

**우선순위**: P0
**의존성**: T1.1

**설명**:
Tailwind CSS 기반으로 도트 픽셀 아트 스타일의 레이아웃을 구성합니다.

**수용 기준**:
- [ ] 우주/사이버펑크 색상 팔레트 설정
- [ ] 픽셀 폰트 (Press Start 2P) 적용
- [ ] 픽셀 버튼, 카드 컴포넌트
- [ ] 네비게이션 바 + 푸터

**예상 파일**:
- `app/views/layouts/application.html.erb`
- `app/assets/stylesheets/pixel.css`
- `app/views/shared/_navbar.html.erb`
- `app/views/shared/_footer.html.erb`

---

### T1.3: 픽셀 캐릭터/로고 생성

**우선순위**: P1
**의존성**: 없음 (병렬 가능)

**설명**:
AnsibleMage 도트 캐릭터와 로고를 생성합니다.

**수용 기준**:
- [ ] 32x32 또는 64x64 픽셀 마법사 캐릭터
- [ ] 픽셀 로고 (텍스트 + 아이콘)
- [ ] SVG 또는 PNG 포맷

**예상 파일**:
- `app/assets/images/mage_character.svg`
- `app/assets/images/logo.svg`

---

### T1.4: 홈페이지 구현

**우선순위**: P0
**의존성**: T1.2, T1.3

**설명**:
메인 홈페이지를 구현합니다. 인트로 애니메이션과 최신 글 미리보기를 포함합니다.

**수용 기준**:
- [ ] PagesController#home
- [ ] 도트 캐릭터 인트로 애니메이션
- [ ] 환영 메시지 + 설명
- [ ] 최신 블로그 글 미리보기 (3개)

**예상 파일**:
- `app/controllers/pages_controller.rb`
- `app/views/pages/home.html.erb`
- `config/routes.rb`

---

### T1.5: About 페이지

**우선순위**: P1
**의존성**: T1.4

**설명**:
AnsibleMage 소개 페이지를 구현합니다.

**수용 기준**:
- [ ] PagesController#about
- [ ] GitHub 프로필 정보 표시
- [ ] 도트 캐릭터 일러스트
- [ ] 기술 스택 (픽셀 아이콘)

**예상 파일**:
- `app/views/pages/about.html.erb`

---

## Sprint 2: 블로그 기능 (M2)

### T2.1: Post 모델

**우선순위**: P0
**의존성**: T1.1

**설명**:
블로그 게시글 모델을 생성합니다.

**수용 기준**:
- [ ] title, slug, content, excerpt, published, likes_count
- [ ] slug 자동 생성 (before_validation)
- [ ] published scope
- [ ] 유효성 검사 (title, content 필수)

**테스트 케이스**:
```ruby
# spec/models/post_spec.rb
it { is_expected.to validate_presence_of(:title) }
it { is_expected.to validate_presence_of(:content) }
it { is_expected.to validate_uniqueness_of(:slug) }
```

**예상 파일**:
- `app/models/post.rb`
- `db/migrate/xxx_create_posts.rb`
- `spec/models/post_spec.rb`

---

### T2.2: 블로그 목록 페이지

**우선순위**: P0
**의존성**: T2.1, T1.2

**설명**:
블로그 글 목록을 도트 스타일 카드로 표시합니다.

**수용 기준**:
- [ ] PostsController#index
- [ ] 픽셀 카드 리스트
- [ ] 제목, 요약, 작성일, 좋아요 수
- [ ] 페이지네이션

**예상 파일**:
- `app/controllers/posts_controller.rb`
- `app/views/posts/index.html.erb`
- `app/views/posts/_post_card.html.erb`

---

### T2.3: 블로그 상세 페이지

**우선순위**: P0
**의존성**: T2.1

**설명**:
블로그 글 상세 페이지를 구현합니다.

**수용 기준**:
- [ ] PostsController#show
- [ ] Markdown 렌더링 (Redcarpet)
- [ ] 코드 하이라이팅 (Rouge)
- [ ] 좋아요 버튼 영역
- [ ] 댓글 영역 (나중에 구현)

**예상 파일**:
- `app/views/posts/show.html.erb`
- `app/helpers/markdown_helper.rb`

---

### T2.4: 관리자 CRUD

**우선순위**: P1
**의존성**: T2.1

**설명**:
관리자용 게시글 CRUD를 구현합니다.

**수용 기준**:
- [ ] Admin::PostsController (new, create, edit, update, destroy)
- [ ] Markdown 에디터
- [ ] 미리보기 기능

**예상 파일**:
- `app/controllers/admin/posts_controller.rb`
- `app/views/admin/posts/`

---

## Sprint 3: 상호작용 (M3)

### T3.1: Like 모델

**우선순위**: P0
**의존성**: T2.1

**설명**:
좋아요 모델을 생성합니다.

**수용 기준**:
- [ ] post_id, ip_address, user_id (nullable)
- [ ] 중복 방지 (IP 또는 User 기준)
- [ ] counter_cache로 likes_count 업데이트

**예상 파일**:
- `app/models/like.rb`
- `db/migrate/xxx_create_likes.rb`

---

### T3.2: 좋아요 UI

**우선순위**: P0
**의존성**: T3.1, T1.2

**설명**:
좋아요 버튼과 픽셀 애니메이션을 구현합니다.

**수용 기준**:
- [ ] LikesController#create
- [ ] 픽셀 하트 아이콘
- [ ] 클릭 시 애니메이션
- [ ] Turbo로 실시간 카운트 업데이트

**예상 파일**:
- `app/controllers/likes_controller.rb`
- `app/views/likes/create.turbo_stream.erb`

---

### T3.3: User 모델

**우선순위**: P0
**의존성**: 없음

**설명**:
GitHub OAuth 사용자 모델을 생성합니다.

**수용 기준**:
- [ ] github_id, github_login, name, avatar_url
- [ ] find_or_create_from_auth_hash 메서드

**예상 파일**:
- `app/models/user.rb`
- `db/migrate/xxx_create_users.rb`

---

### T3.4: GitHub OAuth

**우선순위**: P0
**의존성**: T3.3

**설명**:
GitHub OAuth 로그인을 구현합니다.

**수용 기준**:
- [ ] OmniAuth 설정
- [ ] SessionsController (create, destroy)
- [ ] 로그인/로그아웃 버튼

**예상 파일**:
- `config/initializers/omniauth.rb`
- `app/controllers/sessions_controller.rb`

---

### T3.5: Comment 모델

**우선순위**: P0
**의존성**: T2.1, T3.3

**설명**:
댓글 모델을 생성합니다.

**수용 기준**:
- [ ] post_id, user_id, content
- [ ] belongs_to :post, :user
- [ ] 유효성 검사

**예상 파일**:
- `app/models/comment.rb`
- `db/migrate/xxx_create_comments.rb`

---

### T3.6: 댓글 UI

**우선순위**: P0
**의존성**: T3.5, T3.4

**설명**:
댓글 작성 및 목록 UI를 구현합니다.

**수용 기준**:
- [ ] CommentsController (create)
- [ ] 댓글 목록 (Turbo Frame)
- [ ] 댓글 작성 폼 (로그인 필요)
- [ ] GitHub 아바타 표시

**예상 파일**:
- `app/controllers/comments_controller.rb`
- `app/views/comments/`

---

## Sprint 4: 완성 (M4)

### T4.1: Projects 페이지

**우선순위**: P1
**의존성**: T1.4

**설명**:
GitHub 레포지토리를 표시하는 페이지를 구현합니다.

**수용 기준**:
- [ ] PagesController#projects
- [ ] GitHub API 연동
- [ ] 레포지토리 카드 (도트 스타일)

**예상 파일**:
- `app/views/pages/projects.html.erb`
- `app/services/github_service.rb`

---

### T4.2: 애니메이션 완성

**우선순위**: P1
**의존성**: T1.2

**설명**:
전체 애니메이션을 완성합니다.

**수용 기준**:
- [ ] 인트로 애니메이션
- [ ] 호버 효과
- [ ] 페이지 트랜지션

**예상 파일**:
- `app/assets/stylesheets/animations.css`
- `app/javascript/controllers/animation_controller.js`

---

### T4.3: 반응형 최적화

**우선순위**: P1
**의존성**: 전체

**설명**:
모바일/태블릿 반응형을 최적화합니다.

**수용 기준**:
- [ ] 모바일 네비게이션
- [ ] 카드 그리드 반응형
- [ ] 폰트 사이즈 조정

---

### T4.4: Kamal 배포 설정

**우선순위**: P0
**의존성**: 전체

**설명**:
Kamal 2 배포 설정을 완료합니다.

**수용 기준**:
- [ ] deploy.yml 작성
- [ ] Dockerfile 최적화
- [ ] 환경 변수 설정

**예상 파일**:
- `config/deploy.yml`
- `Dockerfile`
- `.kamal/secrets`

---

### T4.5: 프로덕션 배포

**우선순위**: P0
**의존성**: T4.4

**설명**:
프로덕션에 배포하고 검증합니다.

**수용 기준**:
- [ ] kamal setup
- [ ] kamal deploy
- [ ] 헬스체크 통과
- [ ] 스모크 테스트 통과

---

## 진행 상황

| 태스크 | 상태 | 완료일 |
|--------|------|--------|
| T1.1 | ⬜ 대기 | |
| T1.2 | ⬜ 대기 | |
| T1.3 | ⬜ 대기 | |
| T1.4 | ⬜ 대기 | |
| T1.5 | ⬜ 대기 | |
| T2.1 | ⬜ 대기 | |
| T2.2 | ⬜ 대기 | |
| T2.3 | ⬜ 대기 | |
| T2.4 | ⬜ 대기 | |
| T3.1 | ⬜ 대기 | |
| T3.2 | ⬜ 대기 | |
| T3.3 | ⬜ 대기 | |
| T3.4 | ⬜ 대기 | |
| T3.5 | ⬜ 대기 | |
| T3.6 | ⬜ 대기 | |
| T4.1 | ⬜ 대기 | |
| T4.2 | ⬜ 대기 | |
| T4.3 | ⬜ 대기 | |
| T4.4 | ⬜ 대기 | |
| T4.5 | ⬜ 대기 | |
