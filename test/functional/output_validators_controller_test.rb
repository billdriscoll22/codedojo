require 'test_helper'

class OutputValidatorsControllerTest < ActionController::TestCase
  setup do
    @output_validator = output_validators(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:output_validators)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create output_validator" do
    assert_difference('OutputValidator.count') do
      post :create, output_validator: { args: @output_validator.args, exercise_id: @output_validator.exercise_id, validator: @output_validator.validator }
    end

    assert_redirected_to output_validator_path(assigns(:output_validator))
  end

  test "should show output_validator" do
    get :show, id: @output_validator
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @output_validator
    assert_response :success
  end

  test "should update output_validator" do
    put :update, id: @output_validator, output_validator: { args: @output_validator.args, exercise_id: @output_validator.exercise_id, validator: @output_validator.validator }
    assert_redirected_to output_validator_path(assigns(:output_validator))
  end

  test "should destroy output_validator" do
    assert_difference('OutputValidator.count', -1) do
      delete :destroy, id: @output_validator
    end

    assert_redirected_to output_validators_path
  end
end
