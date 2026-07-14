require "test_helper"

class TelemetryTest < ActiveSupport::TestCase
  setup { Telemetry.reset! }
  teardown { Telemetry.reset! }

  def sample(duration)
    Telemetry::Sample.new(
      controller: "ProjectsController",
      action: "index",
      status: 200,
      duration: duration,
      db_runtime: 1.0,
      view_runtime: 1.0,
      at: Time.current
    )
  end

  test "records samples and computes aggregate stats" do
    [ 10.0, 20.0, 30.0 ].each { |d| Telemetry.record(sample(d)) }

    stats = Telemetry.stats
    assert_equal 3, stats[:count]
    assert_equal 20.0, stats[:avg]
    assert_equal 30.0, stats[:max]
    assert_equal 3, stats[:recent].size
  end

  test "caps the ring buffer at MAX_SAMPLES" do
    (Telemetry::MAX_SAMPLES + 25).times { Telemetry.record(sample(5.0)) }

    assert_equal Telemetry::MAX_SAMPLES, Telemetry.stats[:count]
  end

  test "reset! clears all samples" do
    Telemetry.record(sample(5.0))
    Telemetry.reset!

    assert_equal 0, Telemetry.stats[:count]
  end

  test "stats are zeroed when there are no samples" do
    stats = Telemetry.stats
    assert_equal 0, stats[:count]
    assert_equal 0.0, stats[:avg]
    assert_equal 0.0, stats[:p95]
  end
end
