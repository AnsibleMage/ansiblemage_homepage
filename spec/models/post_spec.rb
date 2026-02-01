require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_uniqueness_of(:slug) }
  end

  describe 'slug generation' do
    it 'generates slug from title before validation' do
      post = Post.new(title: 'Hello World', content: 'Test content')
      post.valid?
      expect(post.slug).to eq('hello-world')
    end

    it 'handles Korean titles' do
      post = Post.new(title: '안녕하세요 세계', content: 'Test content')
      post.valid?
      expect(post.slug).to be_present
    end

    it 'handles duplicate slugs by appending number' do
      Post.create!(title: 'Hello World', content: 'First post')
      post = Post.new(title: 'Hello World', content: 'Second post')
      post.valid?
      expect(post.slug).to match(/hello-world-\d+/)
    end
  end

  describe 'excerpt generation' do
    it 'generates excerpt from content if not provided' do
      post = Post.new(title: 'Test', content: 'A' * 300)
      post.valid?
      expect(post.excerpt).to be_present
      expect(post.excerpt.length).to be <= 200
    end

    it 'does not override provided excerpt' do
      post = Post.new(title: 'Test', content: 'Long content', excerpt: 'Custom excerpt')
      post.valid?
      expect(post.excerpt).to eq('Custom excerpt')
    end
  end

  describe 'scopes' do
    let!(:published_post) { Post.create!(title: 'Published', content: 'Content', published: true) }
    let!(:draft_post) { Post.create!(title: 'Draft', content: 'Content', published: false) }

    describe '.published' do
      it 'returns only published posts' do
        expect(Post.published).to include(published_post)
        expect(Post.published).not_to include(draft_post)
      end
    end

    describe '.drafts' do
      it 'returns only draft posts' do
        expect(Post.drafts).to include(draft_post)
        expect(Post.drafts).not_to include(published_post)
      end
    end
  end

  describe 'default values' do
    it 'defaults published to false' do
      post = Post.new(title: 'Test', content: 'Content')
      expect(post.published).to be false
    end

    it 'defaults likes_count to 0' do
      post = Post.new(title: 'Test', content: 'Content')
      expect(post.likes_count).to eq(0)
    end
  end
end
