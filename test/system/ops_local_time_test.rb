require "application_system_test_case"

class OpsLocalTimeTest < ApplicationSystemTestCase
  # The dashboard renders clocks in UTC and lets Stimulus rewrite them into
  # whatever zone the visitor is in. These assert the rewrite against the
  # offset the browser itself reports, so they hold in CI regardless of the
  # machine's zone.
  test "clocks are rewritten into the visitor's time zone" do
    visit ops_path
    clock = find("time[data-controller='local-time']", match: :first)
    utc = Time.iso8601(clock[:datetime])

    # getTimezoneOffset is minutes *behind* UTC, so Lima (UTC-5) reports 300.
    offset_minutes = page.evaluate_script("new Date().getTimezoneOffset()")
    expected = (utc - offset_minutes * 60).strftime("%H:%M:%S")

    assert_selector "time[datetime='#{clock[:datetime]}']", text: expected
  end

  test "the clock keeps a machine-readable UTC instant regardless of display" do
    visit ops_path
    clock = find("time[data-controller='local-time']", match: :first)

    assert_match(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z\z/, clock[:datetime])
  end
end
