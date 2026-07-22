# In-memory, thread-safe ring buffer that captures recent HTTP request
# telemetry. It is populated by an ActiveSupport::Notifications subscriber
# (see config/initializers/telemetry.rb).
#
# Data is per-process and resets on boot, which is acceptable for a live
# operations dashboard whose purpose is to visualise current activity.
class Telemetry
  Sample = Data.define(:controller, :action, :status, :duration, :db_runtime, :view_runtime, :at)

  MAX_SAMPLES = 200

  @mutex = Mutex.new
  @samples = []

  class << self
    def record(sample)
      @mutex.synchronize do
        @samples.push(sample)
        @samples.shift while @samples.size > MAX_SAMPLES
      end
    end

    def samples
      @mutex.synchronize { @samples.dup }
    end

    def reset!
      @mutex.synchronize { @samples.clear }
    end

    def stats
      data = samples
      durations = data.map(&:duration)
      server_errors = data.count { |s| s.status.to_i >= 500 }

      {
        count: data.size,
        avg: average(durations),
        p95: percentile(durations, 95),
        max: (durations.max || 0.0).round(1),
        avg_db: average(data.map(&:db_runtime)),
        server_errors: server_errors,
        client_errors: data.count { |s| (400..499).cover?(s.status.to_i) },
        error_rate: data.empty? ? 0.0 : (server_errors * 100.0 / data.size).round(1),
        rpm: data.count { |s| s.at > 60.seconds.ago },
        history: durations.last(60),
        recent: data.last(10).reverse
      }
    end

    private

    def average(values)
      return 0.0 if values.empty?

      (values.sum / values.size).round(1)
    end

    def percentile(values, pct)
      return 0.0 if values.empty?

      sorted = values.sort
      rank = (pct / 100.0) * (sorted.size - 1)
      lower = sorted[rank.floor]
      upper = sorted[rank.ceil]
      (lower + (upper - lower) * (rank - rank.floor)).round(1)
    end
  end
end
