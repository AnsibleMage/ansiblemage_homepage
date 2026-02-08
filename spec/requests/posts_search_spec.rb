require 'rails_helper'

RSpec.describe "Posts Search", type: :request do
  let!(:post1) { create(:post, title: 'Ruby Tutorial', content: 'Learn Ruby', published: true) }
  let!(:post2) { create(:post, title: 'JavaScript Guide', content: 'Learn JavaScript', published: true) }

  describe "GET /posts" do
    context "with search query" do
      it "returns posts matching the search query" do
        get posts_path, params: { q: 'Ruby' }
        expect(response).to have_http_status(:success)
        expect(response.body).to include('Ruby Tutorial')
        expect(response.body).not_to include('JavaScript Guide')
      end

      it "returns all posts when query is empty" do
        get posts_path, params: { q: '' }
        expect(response).to have_http_status(:success)
        expect(response.body).to include('Ruby Tutorial')
        expect(response.body).to include('JavaScript Guide')
      end
    end

    context "without search query" do
      it "returns all published posts" do
        get posts_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include('Ruby Tutorial')
        expect(response.body).to include('JavaScript Guide')
      end
    end

    context "with both search and tag filter" do
      let!(:tagged_post) { create(:post, title: 'Ruby Rails Guide', content: 'Rails framework', tags: ['ruby', 'rails'].to_json, published: true) }

      it "prioritizes search over tag filter" do
        get posts_path, params: { q: 'Ruby', tag: 'rails' }
        expect(response).to have_http_status(:success)
        # Search should take precedence and find both Ruby posts
        expect(response.body).to include('Ruby Tutorial')
        expect(response.body).to include('Ruby Rails Guide')
      end
    end
  end
end
