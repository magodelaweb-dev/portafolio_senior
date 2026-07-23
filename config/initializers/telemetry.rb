# Record the boot time so the /ops dashboard can display process uptime.
Rails.application.config.x.booted_at = Time.current

# Subscribe to controller actions and feed request telemetry into Telemetry.
# The block references the reloadable Telemetry constant lazily (at event
# time), so it stays correct across code reloads in development.
ActiveSupport::Notifications.subscribe("process_action.action_controller") do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  payload = event.payload

  # Skip the dashboard's own polling requests to avoid self-referential noise.
  next if payload[:controller] == "OpsController"

  Telemetry.record(
    Telemetry::Sample.new(
      controller: payload[:controller],
      action: payload[:action],
      status: payload[:status],
      duration: event.duration.round(1),
      db_runtime: (payload[:db_runtime] || 0.0).round(1),
      view_runtime: (payload[:view_runtime] || 0.0).round(1),
      # event.end is a monotonic-clock Float in modern Rails; the dashboard
      # needs wall-clock Times (rpm compares against 60.seconds.ago).
      at: Time.current
    )
  )
end
