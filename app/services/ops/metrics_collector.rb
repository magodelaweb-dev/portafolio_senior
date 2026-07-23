module Ops
  # Gathers a point-in-time snapshot of application, database, Solid Queue,
  # Solid Cache and request-telemetry metrics for the /ops dashboard.
  class MetricsCollector
    def self.call
      new.call
    end

    def call
      {
        app: app_metrics,
        databases: database_metrics,
        queue: queue_metrics,
        cache: cache_metrics,
        requests: Telemetry.stats,
        generated_at: Time.current
      }
    end

    private

    def app_metrics
      {
        rails: Rails::VERSION::STRING,
        ruby: RUBY_VERSION,
        env: Rails.env,
        pid: Process.pid,
        uptime: uptime,
        memory_mb: memory_mb
      }
    end

    # Resident memory of this process in MB, read from /proc (Linux-only,
    # which matches every environment this app runs on). nil elsewhere.
    def memory_mb
      line = File.foreach("/proc/self/status").find { |l| l.start_with?("VmRSS:") }
      line && (line.split[1].to_f / 1024).round
    rescue SystemCallError, IOError
      nil
    end

    def uptime
      booted_at = Rails.application.config.x.booted_at
      return "n/a" unless booted_at

      seconds = (Time.current - booted_at).to_i
      format("%<h>02dh %<m>02dm %<s>02ds", h: seconds / 3600, m: (seconds % 3600) / 60, s: seconds % 60)
    end

    def database_metrics
      ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).map do |config|
        path = Rails.root.join(config.database)
        {
          name: config.name,
          path: config.database,
          size: File.exist?(path) ? File.size(path) : 0
        }
      end
    end

    def queue_metrics
      {
        available: true,
        ready: SolidQueue::ReadyExecution.count,
        scheduled: SolidQueue::ScheduledExecution.count,
        in_progress: SolidQueue::ClaimedExecution.count,
        failed: SolidQueue::FailedExecution.count,
        finished: SolidQueue::Job.where.not(finished_at: nil).count,
        total: SolidQueue::Job.count,
        processes: SolidQueue::Process.count,
        recent: recent_jobs
      }
    rescue StandardError => e
      { available: false, error: e.message }
    end

    def recent_jobs
      SolidQueue::Job.order(created_at: :desc).limit(8).map do |job|
        {
          class_name: job.class_name,
          queue: job.queue_name,
          status: job_status(job),
          at: job.created_at
        }
      end
    end

    def job_status(job)
      return "finished" if job.finished_at
      return "failed" if job.failed_execution.present?
      return "scheduled" if job.scheduled_at && job.scheduled_at > Time.current

      "ready"
    end

    def cache_metrics
      { available: true, entries: SolidCache::Entry.count }
    rescue StandardError => e
      { available: false, error: e.message }
    end
  end
end
