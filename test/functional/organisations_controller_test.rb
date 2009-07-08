require 'test_helper'

class OrganisationsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:organisations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create organisation" do
    assert_difference('Organisation.count') do
      post :create, :organisation => { }
    end

    assert_redirected_to organisation_path(assigns(:organisation))
  end

  test "should show organisation" do
    get :show, :id => organisations(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => organisations(:one).to_param
    assert_response :success
  end

  test "should update organisation" do
    put :update, :id => organisations(:one).to_param, :organisation => { }
    assert_redirected_to organisation_path(assigns(:organisation))
  end

  test "should destroy organisation" do
    assert_difference('Organisation.count', -1) do
      delete :destroy, :id => organisations(:one).to_param
    end

    assert_redirected_to organisations_path
  end
end
