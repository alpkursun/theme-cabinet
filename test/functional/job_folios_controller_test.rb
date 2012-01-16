require 'test_helper'

class JobFoliosControllerTest < ActionController::TestCase
  setup do
    @job_folio = job_folios(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:job_folios)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create job_folio" do
    assert_difference('JobFolio.count') do
      post :create, job_folio: @job_folio.attributes
    end

    assert_redirected_to job_folio_path(assigns(:job_folio))
  end

  test "should show job_folio" do
    get :show, id: @job_folio.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @job_folio.to_param
    assert_response :success
  end

  test "should update job_folio" do
    put :update, id: @job_folio.to_param, job_folio: @job_folio.attributes
    assert_redirected_to job_folio_path(assigns(:job_folio))
  end

  test "should destroy job_folio" do
    assert_difference('JobFolio.count', -1) do
      delete :destroy, id: @job_folio.to_param
    end

    assert_redirected_to job_folios_path
  end
end
