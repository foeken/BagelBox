require 'test_helper'

class DataFileFiltersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:data_file_filters)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create data_file_filter" do
    assert_difference('DataFileFilter.count') do
      post :create, :data_file_filter => { }
    end

    assert_redirected_to data_file_filter_path(assigns(:data_file_filter))
  end

  test "should show data_file_filter" do
    get :show, :id => data_file_filters(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => data_file_filters(:one).to_param
    assert_response :success
  end

  test "should update data_file_filter" do
    put :update, :id => data_file_filters(:one).to_param, :data_file_filter => { }
    assert_redirected_to data_file_filter_path(assigns(:data_file_filter))
  end

  test "should destroy data_file_filter" do
    assert_difference('DataFileFilter.count', -1) do
      delete :destroy, :id => data_file_filters(:one).to_param
    end

    assert_redirected_to data_file_filters_path
  end
end
