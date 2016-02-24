require 'test_helper'

class TemplateFilesControllerTest < ActionController::TestCase
  setup do
    @template_file = template_files(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:template_files)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create template_file" do
    assert_difference('TemplateFile.count') do
      post :create, template_file: { content: @template_file.content, exercise_id: @template_file.exercise_id, file_name: @template_file.file_name }
    end

    assert_redirected_to template_file_path(assigns(:template_file))
  end

  test "should show template_file" do
    get :show, id: @template_file
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @template_file
    assert_response :success
  end

  test "should update template_file" do
    put :update, id: @template_file, template_file: { content: @template_file.content, exercise_id: @template_file.exercise_id, file_name: @template_file.file_name }
    assert_redirected_to template_file_path(assigns(:template_file))
  end

  test "should destroy template_file" do
    assert_difference('TemplateFile.count', -1) do
      delete :destroy, id: @template_file
    end

    assert_redirected_to template_files_path
  end
end
