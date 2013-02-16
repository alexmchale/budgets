class ApplicationController < ActionController::Base

  protect_from_forgery
  helper_method :current_account

  def current_account
    @_current_account ||= Account.find(1)
  end

end
