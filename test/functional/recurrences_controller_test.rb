require 'test_helper'

class RecurrencesControllerTest < ActionController::TestCase
  setup do
    @recurrence = recurrences(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:recurrences)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create recurrence" do
    assert_difference('Recurrence.count') do
      post :create, recurrence: {  }
    end

    assert_redirected_to recurrence_path(assigns(:recurrence))
  end

  test "should show recurrence" do
    get :show, id: @recurrence
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @recurrence
    assert_response :success
  end

  test "should update recurrence" do
    put :update, id: @recurrence, recurrence: {  }
    assert_redirected_to recurrence_path(assigns(:recurrence))
  end

  test "should destroy recurrence" do
    assert_difference('Recurrence.count', -1) do
      delete :destroy, id: @recurrence
    end

    assert_redirected_to recurrences_path
  end
end
