# A lightweight demo job so the /ops dashboard shows real Solid Queue activity.
# Enqueue it from the dashboard button or with:
#   DemoTelemetryJob.perform_later("hello")
class DemoTelemetryJob < ApplicationJob
  queue_as :default

  def perform(label = "demo")
    sleep(rand(0.2..1.2))
    Rails.logger.info("DemoTelemetryJob processed: #{label}")
  end
end
