require 'rails_helper'

RSpec.describe "Posts Tag Filtering", type: :request do
  describe "GET /posts with tag parameter" do
    before do
      @ruby_post = Post.create!(
        title: 'Ruby Tutorial',
        content: 'Learn Ruby programming',
        published: true,
        tags: ['Ruby', 'Programming']
      )

      @rails_post = Post.create!(
        title: 'Rails Guide',
        content: 'Build web apps with Rails',
        published: true,
        tags: ['Ruby', 'Rails', 'Web']
      )

      @js_post = Post.create!(
        title: 'JavaScript Basics',
        content: 'Learn JavaScript',
        published: true,
        tags: ['JavaScript', 'Web']
      )

      @draft_post = Post.create!(
        title: 'Draft Post',
        content: 'Not published',
        published: false,
        tags: ['Ruby']
      )
    end

    it 'returns all published posts when no tag filter' do
      get posts_path
      expect(response).to have_http_status(:success)
      expect(assigns(:posts)).to include(@ruby_post, @rails_post, @js_post)
      expect(assigns(:posts)).not_to include(@draft_post)
    end

    it 'filters posts by Ruby tag' do
      get posts_path(tag: 'Ruby')
      expect(response).to have_http_status(:success)
      expect(assigns(:posts)).to include(@ruby_post, @rails_post)
      expect(assigns(:posts)).not_to include(@js_post, @draft_post)
    end

    it 'filters posts by Rails tag' do
      get posts_path(tag: 'Rails')
      expect(response).to have_http_status(:success)
      expect(assigns(:posts)).to include(@rails_post)
      expect(assigns(:posts)).not_to include(@ruby_post, @js_post)
    end

    it 'filters posts by Web tag' do
      get posts_path(tag: 'Web')
      expect(response).to have_http_status(:success)
      expect(assigns(:posts)).to include(@rails_post, @js_post)
      expect(assigns(:posts)).not_to include(@ruby_post)
    end

    it 'returns empty when filtering by non-existent tag' do
      get posts_path(tag: 'NonExistent')
      expect(response).to have_http_status(:success)
      expect(assigns(:posts)).to be_empty
    end

    it 'provides all_tags for filter display' do
      get posts_path
      expect(response).to have_http_status(:success)
      expect(assigns(:all_tags)).to contain_exactly(
        'JavaScript', 'Programming', 'Rails', 'Ruby', 'Web'
      )
    end

    it 'excludes draft post tags from all_tags' do
      get posts_path
      expect(assigns(:all_tags).count { |t| t == 'Ruby' }).to eq(1)
    end
  end
end
