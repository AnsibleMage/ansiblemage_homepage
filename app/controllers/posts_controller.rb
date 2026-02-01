class PostsController < ApplicationController
  def index
    @posts = Post.published.recent
  end

  def show
    @post = Post.find_by!(slug: params[:id])
    @liked = user_liked?(@post)
    @comments = @post.comments.includes(:user).order(created_at: :desc) if defined?(Comment)
  end

  private

  def user_liked?(post)
    if current_user
      post.likes.exists?(user: current_user)
    else
      post.likes.exists?(ip_address: request.remote_ip, user: nil)
    end
  end
end
