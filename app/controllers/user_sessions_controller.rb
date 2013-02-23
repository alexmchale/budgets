class UserSessionsController < ApplicationController

  def new
  end

  def create
    user = User.where("email ILIKE ?", params[:email]).first

    if user != nil && user.password == params[:password]
      self.current_user = user
      redirect_to transactions_path
    else
      flash.now[:error] = "Invalid email or password, please try again."
      render :new
    end
  end

  def destroy
    self.current_user = nil
    redirect_to new_user_session_path
  end

end
