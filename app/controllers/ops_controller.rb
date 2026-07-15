class OpsController < ApplicationController
  allow_unauthenticated_access only: %i[ index metrics ]

  # GET /ops
  def index
  end

  # GET /ops/metrics -> live-updating fragment polled by the dashboard.
  def metrics
    render partial: "ops/metrics", locals: { metrics: Ops::MetricsCollector.call }
  end

  # POST /ops/enqueue -> enqueue a demo job to show live Solid Queue activity.
  # Responds with a Turbo Stream that refreshes the dashboard instantly (while
  # keeping the frame's src + polling intact), falling back to a redirect.
  def enqueue
    DemoTelemetryJob.perform_later("manual-#{Time.current.to_i}")

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          "ops_metrics",
          partial: "ops/dashboard",
          locals: { metrics: Ops::MetricsCollector.call }
        )
      end
      format.html { redirect_to ops_path, notice: "Job de demostración encolado." }
    end
  end
end
