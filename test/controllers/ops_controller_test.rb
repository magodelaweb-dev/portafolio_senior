require "test_helper"

class OpsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "index renders the operations dashboard" do
    get ops_url
    assert_response :success
    assert_select "h1", text: "Panel de operaciones"
  end

  test "metrics renders the live fragment with all sections" do
    get ops_metrics_url
    assert_response :success
    assert_match "Solid Queue", @response.body
    assert_match "Solid Cache", @response.body
    assert_match "turbo-frame", @response.body
  end

  test "enqueue schedules a demo job and redirects to the dashboard" do
    assert_enqueued_with(job: DemoTelemetryJob) do
      post ops_enqueue_url
    end
    assert_redirected_to ops_path
  end

  test "enqueue via Turbo Stream updates the dashboard in place" do
    assert_enqueued_with(job: DemoTelemetryJob) do
      post ops_enqueue_url, as: :turbo_stream
    end
    assert_response :success
    assert_match "text/vnd.turbo-stream.html", @response.media_type
    assert_match(/<turbo-stream action="update" target="ops_metrics">/, @response.body)
  end
end
