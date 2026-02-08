require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'tags functionality' do
    describe '#tags=' do
      it 'accepts and stores array of tags' do
        post = Post.new(title: 'Test', content: 'Content')
        post.tags = ['Ruby', 'Rails', 'Tutorial']
        post.save!

        expect(post.reload.tags).to eq(['Ruby', 'Rails', 'Tutorial'])
      end

      it 'accepts comma-separated string and converts to array' do
        post = Post.new(title: 'Test', content: 'Content')
        post.tags = 'Ruby, Rails, Tutorial'
        post.save!

        expect(post.reload.tags).to eq(['Ruby', 'Rails', 'Tutorial'])
      end

      it 'removes duplicate tags' do
        post = Post.new(title: 'Test', content: 'Content')
        post.tags = ['Ruby', 'Rails', 'Ruby']
        post.save!

        expect(post.reload.tags).to eq(['Ruby', 'Rails'])
      end

      it 'trims whitespace from tags' do
        post = Post.new(title: 'Test', content: 'Content')
        post.tags = '  Ruby  ,  Rails  ,  Tutorial  '
        post.save!

        expect(post.reload.tags).to eq(['Ruby', 'Rails', 'Tutorial'])
      end

      it 'handles empty values' do
        post = Post.new(title: 'Test', content: 'Content')
        post.tags = nil
        post.save!

        expect(post.reload.tags).to eq([])
      end
    end

    describe '#tags' do
      it 'returns empty array when tags column is nil' do
        post = Post.create!(title: 'Test', content: 'Content', tags: nil)
        expect(post.tags).to eq([])
      end

      it 'returns empty array when tags column is empty string' do
        post = Post.create!(title: 'Test', content: 'Content')
        post.update_column(:tags, '')
        expect(post.tags).to eq([])
      end

      it 'handles JSON parse errors gracefully' do
        post = Post.create!(title: 'Test', content: 'Content')
        post.update_column(:tags, 'invalid json')
        expect(post.tags).to eq([])
      end
    end

    describe '.all_tags' do
      before do
        Post.create!(title: 'Post 1', content: 'Content', published: true, tags: ['Ruby', 'Rails'])
        Post.create!(title: 'Post 2', content: 'Content', published: true, tags: ['Ruby', 'JavaScript'])
        Post.create!(title: 'Post 3', content: 'Content', published: true, tags: ['Python'])
        Post.create!(title: 'Draft', content: 'Content', published: false, tags: ['Secret'])
      end

      it 'returns all unique tags from published posts' do
        tags = Post.all_tags
        expect(tags).to contain_exactly('JavaScript', 'Python', 'Rails', 'Ruby')
      end

      it 'excludes tags from draft posts' do
        expect(Post.all_tags).not_to include('Secret')
      end

      it 'returns sorted tags' do
        tags = Post.all_tags
        expect(tags).to eq(tags.sort)
      end

      it 'returns empty array when no posts have tags' do
        Post.destroy_all
        Post.create!(title: 'No tags', content: 'Content', published: true)
        expect(Post.all_tags).to eq([])
      end
    end

    describe '.tagged_with' do
      before do
        @ruby_post = Post.create!(title: 'Ruby Post', content: 'Content', published: true, tags: ['Ruby', 'Rails'])
        @js_post = Post.create!(title: 'JS Post', content: 'Content', published: true, tags: ['JavaScript'])
        @multi_post = Post.create!(title: 'Multi Post', content: 'Content', published: true, tags: ['Ruby', 'JavaScript'])
      end

      it 'returns posts with the specified tag' do
        results = Post.tagged_with('Ruby')
        expect(results).to include(@ruby_post, @multi_post)
        expect(results).not_to include(@js_post)
      end

      it 'returns posts with JavaScript tag' do
        results = Post.tagged_with('JavaScript')
        expect(results).to include(@js_post, @multi_post)
        expect(results).not_to include(@ruby_post)
      end

      it 'returns all posts when tag is nil' do
        expect(Post.tagged_with(nil).count).to eq(3)
      end

      it 'returns all posts when tag is empty string' do
        expect(Post.tagged_with('').count).to eq(3)
      end

      it 'returns empty relation when tag not found' do
        expect(Post.tagged_with('NonExistent')).to be_empty
      end
    end
  end
end
