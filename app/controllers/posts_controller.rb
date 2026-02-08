class PostsController < ApplicationController
  include PostLikeable

  before_action :set_post, only: [:show]

  def index
    # Search takes precedence over tag filtering
    if params[:q].present?
      @posts = Post.search(params[:q])
    else
      @posts = Post.published.recent
      @posts = @posts.tagged_with(params[:tag]) if params[:tag].present?
    end
    @all_tags = Post.all_tags
  end

  def show
    @liked = user_liked?
    @comments = @post.comments.includes(:user).order(created_at: :desc) if defined?(Comment)
  end
end
