require 'test_helper'

class TestFilesControllerTest < ActionController::TestCase
  setup do
    @test_file = test_files(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:test_files)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create test_file" do
    assert_difference('TestFile.count') do
      post :create, test_file: { content: @test_file.content, exercise_id: @test_file.exercise_id, file_name: @test_file.file_name }
    end

    assert_redirected_to test_file_path(assigns(:test_file))
  end

  test "should show test_file" do
    get :show, id: @test_file
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @test_file
    assert_response :success
  end

  test "should update test_file" do
    put :update, id: @test_file, test_file: { content: @test_file.content, exercise_id: @test_file.exercise_id, file_name: @test_file.file_name }
    assert_redirected_to test_file_path(assigns(:test_file))
  end

  test "should destroy test_file" do
    assert_difference('TestFile.count', -1) do
      delete :destroy, id: @test_file
    end

    assert_redirected_to test_files_path
  end
end
