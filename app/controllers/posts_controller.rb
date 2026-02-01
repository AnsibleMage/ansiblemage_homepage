class PostsController < ApplicationController
  def index
    @posts = Post.published.recent
  end

  def show
    @post = Post.find_by!(slug: params[:id])
    @comments = @post.comments.includes(:user).order(created_at: :desc) if defined?(Comment)
  end
end
