require 'test_helper'

class DevFoliosControllerTest < ActionController::TestCase
  setup do
    @dev_folio = dev_folios(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:dev_folios)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create dev_folio" do
    assert_difference('DevFolio.count') do
      post :create, dev_folio: @dev_folio.attributes
    end

    assert_redirected_to dev_folio_path(assigns(:dev_folio))
  end

  test "should show dev_folio" do
    get :show, id: @dev_folio.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @dev_folio.to_param
    assert_response :success
  end

  test "should update dev_folio" do
    put :update, id: @dev_folio.to_param, dev_folio: @dev_folio.attributes
    assert_redirected_to dev_folio_path(assigns(:dev_folio))
  end

  test "should destroy dev_folio" do
    assert_difference('DevFolio.count', -1) do
      delete :destroy, id: @dev_folio.to_param
    end

    assert_redirected_to dev_folios_path
  end
end
