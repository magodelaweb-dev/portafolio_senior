require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Named so tests that resize the window can restore the default afterwards.
  SCREEN_SIZE = [ 1400, 1400 ].freeze

  driven_by :selenium, using: :headless_chrome, screen_size: SCREEN_SIZE
end
