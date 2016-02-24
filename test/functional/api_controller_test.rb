require 'test_helper'

class ApiControllerTest < ActionController::TestCase
  test "should get compile" do
    get :compile
    assert_response :success
  end

  test "should get submit_results" do
    get :submit_results
    assert_response :success
  end

  test "should get get_tests" do
    get :get_tests
    assert_response :success
  end

end
