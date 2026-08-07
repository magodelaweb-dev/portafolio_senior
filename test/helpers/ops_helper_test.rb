require "test_helper"

class OpsHelperTest < ActionView::TestCase
  test "ops_local_time carries the UTC instant in the datetime attribute" do
    html = ops_local_time(Time.utc(2026, 8, 7, 23, 12, 0))
    assert_includes html, %(datetime="2026-08-07T23:12:00Z")
  end

  test "ops_local_time renders the server-side clock as fallback content" do
    html = ops_local_time(Time.utc(2026, 8, 7, 23, 12, 0))
    assert_includes html, ">23:12:00</time>"
  end

  test "ops_local_time normalizes a zoned time to UTC" do
    html = ops_local_time(Time.utc(2026, 8, 7, 23, 12, 0).in_time_zone("America/Lima"))
    assert_includes html, %(datetime="2026-08-07T23:12:00Z")
    assert_includes html, ">23:12:00</time>"
  end

  test "ops_local_time hooks up the Stimulus controller" do
    assert_includes ops_local_time(Time.current), %(data-controller="local-time")
  end
end
