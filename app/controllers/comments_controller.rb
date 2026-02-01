# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :require_login
  before_action :set_post
  before_action :set_comment, only: [:destroy]

  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @post, notice: "Comment posted!" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :create_error, status: :unprocessable_entity }
        format.html { redirect_to @post, alert: "Failed to post comment" }
      end
    end
  end

  def destroy
    if @comment.user == current_user || current_user&.admin?
      @comment.destroy
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @post, notice: "Comment deleted" }
      end
    else
      redirect_to @post, alert: "Not authorized"
    end
  end

  private

  def set_post
    @post = Post.find_by!(slug: params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
