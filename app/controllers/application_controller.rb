class ApplicationController < ActionController::Base

  protect_from_forgery
  helper_method :current_user, :current_account

  def current_user
    @_current_user ||= User.find_by_id(session[:user_id])
  end

  def current_user=(user)
    @_current_user = nil
    @_current_account = nil

    if user.nil?
      session[:user_id] = nil
    else
      session[:user_id] = user.id
    end
  end

  def current_account
    @_current_account ||= current_user.account
    @_current_account ||= Account.create!(:user_id => current_user.id)
  end

  def check_logged_in!
    redirect_to sign_in_path unless current_user
  end

end
