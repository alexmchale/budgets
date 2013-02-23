class AccountsController < ApplicationController

  before_filter :check_logged_in!

  def edit_balance
    @account = Account.find(params[:id])
    render partial: "edit_balance_modal", locals: { account: @account }
  end

  def update
    @account = Account.find(params[:id])

    if @account.update_attributes(account_params)
      redirect_to transactions_path
    else
      render partial: "edit_balance_modal", locals: { account: @account }
    end
  end

  private

  def account_params
    params.require(:account).permit(:stated_balance)
  end

end
