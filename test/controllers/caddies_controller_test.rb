require 'test_helper'

class CaddiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @caddy = caddies(:one)
  end

  test "should get index" do
    get caddies_url
    assert_response :success
  end

  test "should get new" do
    get new_caddy_url
    assert_response :success
  end

  test "should create caddy" do
    assert_difference('Caddy.count') do
      post caddies_url, params: { caddy: { first_name: @caddy.first_name, last_name: @caddy.last_name } }
    end

    assert_redirected_to caddy_url(Caddy.last)
  end

  test "should show caddy" do
    get caddy_url(@caddy)
    assert_response :success
  end

  test "should get edit" do
    get edit_caddy_url(@caddy)
    assert_response :success
  end

  test "should update caddy" do
    patch caddy_url(@caddy), params: { caddy: { first_name: @caddy.first_name, last_name: @caddy.last_name } }
    assert_redirected_to caddy_url(@caddy)
  end

  test "should destroy caddy" do
    assert_difference('Caddy.count', -1) do
      delete caddy_url(@caddy)
    end

    assert_redirected_to caddies_url
  end
end
