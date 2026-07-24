require "test_helper"

class CanonicalHostTest < ActionDispatch::IntegrationTest
  test "redirects the www hostname to the apex" do
    get "http://www.magodelaweb.com/"

    assert_response :moved_permanently
    assert_equal "http://magodelaweb.com/", response.location
  end

  test "keeps the path and query string when redirecting" do
    get "http://www.magodelaweb.com/projects?page=2"

    assert_response :moved_permanently
    assert_equal "http://magodelaweb.com/projects?page=2", response.location
  end

  test "redirects non-GET requests to the apex as well" do
    post "http://www.magodelaweb.com/ops/enqueue"

    assert_response :moved_permanently
    assert_equal "http://magodelaweb.com/ops/enqueue", response.location
  end

  test "serves the apex directly without redirecting" do
    get "http://magodelaweb.com/"

    assert_response :success
  end
end
