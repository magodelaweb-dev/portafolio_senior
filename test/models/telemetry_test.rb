require "test_helper"

class TelemetryTest < ActiveSupport::TestCase
  setup { Telemetry.reset! }
  teardown { Telemetry.reset! }

  def sample(duration, status: 200, at: Time.current)
    Telemetry::Sample.new(
      controller: "ProjectsController",
      action: "index",
      status: status,
      duration: duration,
      db_runtime: 1.0,
      view_runtime: 1.0,
      at: at
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
    assert_equal 0.0, stats[:error_rate]
    assert_equal 0, stats[:rpm]
  end

  test "computes error counts and rate from statuses" do
    Telemetry.record(sample(10.0, status: 200))
    Telemetry.record(sample(10.0, status: 404))
    Telemetry.record(sample(10.0, status: 500))
    Telemetry.record(sample(10.0, status: 503))

    stats = Telemetry.stats
    assert_equal 2, stats[:server_errors]
    assert_equal 1, stats[:client_errors]
    assert_equal 50.0, stats[:error_rate]
  end

  test "rpm only counts samples from the last minute" do
    Telemetry.record(sample(10.0, at: 5.minutes.ago))
    Telemetry.record(sample(10.0, at: 30.seconds.ago))
    Telemetry.record(sample(10.0))

    assert_equal 2, Telemetry.stats[:rpm]
  end

  test "history returns recent durations for the sparkline" do
    70.times { |i| Telemetry.record(sample(i.to_f)) }

    history = Telemetry.stats[:history]
    assert_equal 60, history.size
    assert_equal 69.0, history.last
  end
end
