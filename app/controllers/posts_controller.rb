class PostsController < ApplicationController
  def index
    @posts = Post.published.order(created_at: :desc) if defined?(Post)
    @posts ||= []
  end

  def show
    @post = Post.find_by!(slug: params[:id]) if defined?(Post)
  end
end
