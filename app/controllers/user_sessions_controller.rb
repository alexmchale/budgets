class UserSessionsController < ApplicationController

  def new
    @use_narrow_container = true
  end

  def create
    @use_narrow_container = true

    user = User.find_by_email(params[:email])

    if user != nil && user.password == params[:password]
      self.current_user = user
      redirect_to transactions_path
    elsif user == nil
      user = User.new
      user.email = params[:email]
      user.password = params[:password]
      if user.save
        self.current_user = user
        redirect_to transactions_path
      else
        flash.now[:error] = "Invalid email or password, please try again."
        render :new
      end
    else
      flash.now[:error] = "Invalid email or password, please try again."
      render :new
    end
  end

  def destroy
    self.current_user = nil
    redirect_to sign_in_path
  end

end
