require 'rails_helper'

RSpec.describe Post, type: :model do
  describe '.search' do
    let!(:post1) { create(:post, title: 'Ruby on Rails Tutorial', content: 'Learn Ruby on Rails', published: true) }
    let!(:post2) { create(:post, title: 'JavaScript Basics', content: 'Introduction to JavaScript', published: true) }
    let!(:post3) { create(:post, title: 'Advanced Rails', content: 'Deep dive into Ruby and Rails framework', published: true) }
    let!(:draft) { create(:post, title: 'Ruby Draft', content: 'Draft content', published: false) }

    context 'when searching by title' do
      it 'returns posts matching the search query' do
        results = Post.search('Ruby')
        expect(results).to include(post1, post3)
        expect(results).not_to include(post2)
      end
    end

    context 'when searching by content' do
      it 'returns posts matching the search query' do
        results = Post.search('JavaScript')
        expect(results).to include(post2)
        expect(results).not_to include(post1, post3)
      end
    end

    context 'when searching with case insensitive query' do
      it 'returns posts regardless of case' do
        results = Post.search('ruby')
        expect(results).to include(post1, post3)
      end
    end

    context 'when search query is blank' do
      it 'returns all published posts' do
        results = Post.search('')
        expect(results).to include(post1, post2, post3)
        expect(results).not_to include(draft)
      end

      it 'returns all published posts when nil' do
        results = Post.search(nil)
        expect(results).to include(post1, post2, post3)
        expect(results).not_to include(draft)
      end
    end

    context 'when no posts match' do
      it 'returns empty relation' do
        results = Post.search('NonExistentTerm')
        expect(results).to be_empty
      end
    end

    context 'SQL injection protection' do
      it 'safely handles malicious input' do
        expect { Post.search("'; DROP TABLE posts; --") }.not_to raise_error
      end
    end
  end
end
