class OpsController < ApplicationController
  # GET /ops
  def index
  end

  # GET /ops/metrics -> live-updating fragment polled by the dashboard.
  def metrics
    render partial: "ops/metrics", locals: { metrics: Ops::MetricsCollector.call }
  end

  # POST /ops/enqueue -> enqueue a demo job to show live Solid Queue activity.
  def enqueue
    DemoTelemetryJob.perform_later("manual-#{Time.current.to_i}")
    redirect_to ops_path, notice: "Job de demostración encolado."
  end
end
