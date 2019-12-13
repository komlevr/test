require 'test_helper'

class CertsControllerTest < ActionDispatch::IntegrationTest
  test "should get status" do
    get certs_status_url
    assert_response :success
  end

end
