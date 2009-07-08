require 'test_helper'

class ReferencesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:references)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create reference" do
    assert_difference('Reference.count') do
      post :create, :reference => { }
    end

    assert_redirected_to reference_path(assigns(:reference))
  end

  test "should show reference" do
    get :show, :id => references(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => references(:one).to_param
    assert_response :success
  end

  test "should update reference" do
    put :update, :id => references(:one).to_param, :reference => { }
    assert_redirected_to reference_path(assigns(:reference))
  end

  test "should destroy reference" do
    assert_difference('Reference.count', -1) do
      delete :destroy, :id => references(:one).to_param
    end

    assert_redirected_to references_path
  end
end
