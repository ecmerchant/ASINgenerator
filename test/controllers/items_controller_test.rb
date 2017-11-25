require 'test_helper'

class ItemsControllerTest < ActionDispatch::IntegrationTest
  test "should get generate" do
    get items_generate_url
    assert_response :success
  end

end
