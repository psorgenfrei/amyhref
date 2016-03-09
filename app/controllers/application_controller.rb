class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def require_user
    unless logged_in?
      flash[:notice] = "Sign in to see that page"
      redirect_to root_path and return
    end
  end

  private
  def current_user
    User.where(:id => session[:current_user]).first rescue false
  end
  helper_method :current_user

  def logged_in?
    current_user.present?
  end
  helper_method :logged_in?

  def logged_out?
    !logged_in?
  end
  helper_method :logged_out?
end
