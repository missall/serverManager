# coding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'server'
  filter_parameter_logging :password
  helper_method :current_user
  
  def auth_current_user
    unless current_user
      flash[:notice] = "你必须登陆后才能访问此页面"
      redirect_to login_path
    else
      
    end
  end

  private

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end
end
