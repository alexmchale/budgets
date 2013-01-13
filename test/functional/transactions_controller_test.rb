require 'test_helper'

class TransactionsControllerTest < ActionController::TestCase

  setup do
    @transaction = FactoryGirl.create(:transaction)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:upcoming_transactions)
    assert_not_nil assigns(:cleared_transactions)
    assert_not_nil assigns(:posted_transactions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create transaction" do
    assert_difference('Transaction.count') do
      post :create, transaction: { amount: @transaction.amount, description: @transaction.description, paid_at: @transaction.paid_at, payee: @transaction.payee, transaction_type: @transaction.transaction_type }
    end

    assert_redirected_to transactions_path
  end

  test "should show transaction" do
    get :show, id: @transaction
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @transaction
    assert_response :success
  end

  test "should update transaction" do
    put :update, id: @transaction, transaction: { amount: @transaction.amount, description: @transaction.description, paid_at: @transaction.paid_at, payee: @transaction.payee, transaction_type: @transaction.transaction_type }
    assert_redirected_to transactions_path
  end

  test "should destroy transaction" do
    assert_difference('Transaction.count', -1) do
      delete :destroy, id: @transaction
    end

    assert_redirected_to transactions_path
  end

end
