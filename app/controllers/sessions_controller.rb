# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    user = User.find_or_create_from_github(auth)

    session[:user_id] = user.id
    flash[:notice] = "Welcome, #{user.display_name}!"

    redirect_to request.env["omniauth.origin"] || root_path
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = "Logged out successfully"
    redirect_to root_path
  end

  def failure
    flash[:alert] = "Authentication failed"
    redirect_to root_path
  end
end
