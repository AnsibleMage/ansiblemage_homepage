# frozen_string_literal: true

class LikesController < ApplicationController
  include PostLikeable

  before_action :set_post

  def create
    @like = @post.likes.build(like_params)

    if @like.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @post, notice: "Thanks for the like!" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :create, status: :unprocessable_entity }
        format.html { redirect_to @post, alert: "Already liked!" }
      end
    end
  end

  def destroy
    @like = find_user_like

    if @like&.destroy
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @post, notice: "Like removed" }
      end
    else
      respond_to do |format|
        format.turbo_stream { head :not_found }
        format.html { redirect_to @post }
      end
    end
  end

  private

  def like_params
    {
      ip_address: request.remote_ip,
      user: current_user
    }
  end
end
