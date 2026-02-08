# frozen_string_literal: true

module PostLikeable
  extend ActiveSupport::Concern

  private

  def set_post
    @post = Post.find_by!(slug: params[:post_id] || params[:id])
  end

  def find_user_like
    if current_user
      # 로그인한 사용자의 경우: user_id로 좋아요 조회
      @post.likes.find_by(user: current_user)
    else
      # 비로그인 사용자의 경우: IP 주소로 좋아요 조회 (user는 nil)
      @post.likes.find_by(ip_address: request.remote_ip, user: nil)
    end
  end

  def user_liked?(post = @post)
    if current_user
      post.likes.exists?(user: current_user)
    else
      post.likes.exists?(ip_address: request.remote_ip, user: nil)
    end
  end
end
