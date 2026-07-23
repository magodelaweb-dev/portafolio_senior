module OpsHelper
  # Health thresholds for the golden-signal cards. Values are opinionated
  # for this app's scale (small SQLite-backed monolith) and documented in
  # the dashboard microcopy so visitors can judge them too.
  def ops_signal_level(signal, value)
    return :none if value.nil?

    case signal
    when :latency then value < 200 ? :ok : value < 500 ? :warn : :crit
    when :errors  then value.zero? ? :ok : value < 2 ? :warn : :crit
    when :memory  then value < 350 ? :ok : value < 600 ? :warn : :crit
    when :backlog then value < 25 ? :ok : value < 100 ? :warn : :crit
    end
  end

  def ops_signal_badge(level)
    label, classes = {
      ok: [ "Saludable", "bg-emerald-100 text-emerald-700 dark:bg-emerald-500/15 dark:text-emerald-300" ],
      warn: [ "Atención", "bg-amber-100 text-amber-700 dark:bg-amber-500/15 dark:text-amber-300" ],
      crit: [ "Crítico", "bg-red-100 text-red-700 dark:bg-red-500/15 dark:text-red-300" ],
      none: [ "n/d", "bg-slate-100 text-slate-500 dark:bg-slate-500/15 dark:text-slate-400" ]
    }.fetch(level)

    tag.span(label, class: "rounded px-1.5 py-0.5 text-xs font-semibold #{classes}")
  end

  # Points for an inline SVG polyline sparkline (0,0 is top-left).
  def ops_sparkline_points(values, width: 240, height: 40)
    return "" if values.size < 2

    max = [ values.max, 1 ].max.to_f
    step = width.to_f / (values.size - 1)
    values.each_with_index.map { |v, i|
      x = (i * step).round(1)
      y = (height - 2 - (v / max) * (height - 6)).round(1)
      "#{x},#{y}"
    }.join(" ")
  end
end
