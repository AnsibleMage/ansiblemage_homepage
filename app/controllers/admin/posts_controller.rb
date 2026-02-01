module Admin
  class PostsController < ApplicationController
    before_action :require_admin
    before_action :set_post, only: [:edit, :update, :destroy]

    def index
      @posts = Post.recent
    end

    def new
      @post = Post.new
    end

    def create
      @post = Post.new(post_params)

      if @post.save
        redirect_to admin_posts_path, notice: "Post created successfully!"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @post.update(post_params)
        redirect_to admin_posts_path, notice: "Post updated successfully!"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @post.destroy
      redirect_to admin_posts_path, notice: "Post deleted successfully!"
    end

    private

    def set_post
      @post = Post.find_by!(slug: params[:id])
    end

    def post_params
      params.require(:post).permit(:title, :content, :excerpt, :published)
    end

    def require_admin
      # Simple admin check - in production, use proper authorization
      unless current_user&.github_login == "AnsibleMage"
        flash[:alert] = "Access denied"
        redirect_to root_path
      end
    end
  end
end
