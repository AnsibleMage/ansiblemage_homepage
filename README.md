# AnsibleMage Homepage

A pixel-art themed personal blog and portfolio website built with Ruby on Rails 8, featuring GitHub OAuth authentication, Markdown blog posts, dark mode, and Kamal deployment.

## Features

### Blog System
- **Markdown Rendering** -- Write posts in Markdown with syntax highlighting via Redcarpet and Rouge
- **Tags & Search** -- Filter posts by tags, full-text search with Stimulus controllers
- **Likes & Comments** -- Interactive engagement with anonymous (IP-based) and authenticated likes
- **Admin Panel** -- CRUD interface for post management at `/admin/posts`

### Authentication
- **GitHub OAuth** -- Sign in with GitHub via OmniAuth
- **User Profiles** -- Synced GitHub avatar, login, and display name

### Design
- **Pixel Art Theme** -- 8-bit/16-bit retro aesthetic with space/cyberpunk color palette
- **Dark Mode Toggle** -- WCAG AA compliant, system preference detection, localStorage persistence, FOUC prevention
- **Pixel Mage Character** -- Custom CSS pixel art avatar with float animation
- **Responsive Layout** -- Mobile-first with Tailwind CSS v4

### Infrastructure
- **Rails 8 Solid Stack** -- Solid Cache, Solid Queue, Solid Cable
- **Kamal Deployment** -- Docker-based deployment with Traefik proxy and Let's Encrypt SSL
- **PWA Support** -- Service worker and web app manifest

## Tech Stack

| Component | Technology |
|-----------|------------|
| Language | Ruby 3.3.0 |
| Framework | Ruby on Rails 8.0.4 |
| Frontend | Hotwire (Turbo + Stimulus), Importmap |
| Styling | Tailwind CSS v4 |
| Asset Pipeline | Propshaft |
| Database | SQLite3 |
| Auth | OmniAuth (GitHub) |
| Markdown | Redcarpet + Rouge |
| Testing | RSpec, Capybara, FactoryBot, SimpleCov |
| Deployment | Kamal / Docker |

## Project Structure

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
│       ├── posts/       # blog listing and detail
│       ├── comments/    # Turbo Stream partials
│       └── shared/      # navbar, footer, pixel mage
├── config/
│   ├── routes.rb
│   ├── deploy.yml       # Kamal deployment config
│   └── initializers/
│       └── omniauth.rb
├── db/
│   ├── schema.rb
│   └── migrate/
├── spec/                # RSpec tests
│   ├── models/
│   ├── requests/
│   └── system/
└── doc/
    ├── PRD.md
    └── DARK_MODE_IMPLEMENTATION.md
```

## Getting Started

### Prerequisites
- Ruby 3.3.0+
- Bundler

### Installation

```bash
git clone https://github.com/AnsibleMage/ansiblemage_homepage.git
cd ansiblemage_homepage
bundle install
bin/rails db:setup
```

### Running

```bash
bin/dev
```

Open `http://localhost:3000` in your browser.

### Testing

```bash
bundle exec rspec
```

## Pages

| Route | Description |
|-------|-------------|
| `/` | Home -- Pixel mage hero, quote, CTA |
| `/about` | About AnsibleMage |
| `/projects` | Project showcase |
| `/posts` | Blog listing with search and tags |
| `/posts/:slug` | Blog post detail with likes and comments |
| `/admin/posts` | Admin post management |

## License

This project is licensed under the [MIT License](LICENSE).
