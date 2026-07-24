require "application_system_test_case"

class MobileNavigationTest < ApplicationSystemTestCase
  # A phone-sized viewport, where the nav collapses behind the menu button.
  MOBILE_SCREEN = [ 390, 844 ].freeze

  # The driver reuses one browser window across tests, so a test that shrank it
  # would otherwise leak that size into the next one.
  teardown { resize_to_desktop }

  test "the nav collapses behind a menu button and opens on tap" do
    resize_to_mobile
    visit root_path

    trigger = find("[data-nav-target='trigger']")
    assert_equal "false", trigger["aria-expanded"]
    assert_no_selector "#mobile-nav a", text: "Sobre mí", visible: true

    trigger.click

    assert_equal "true", trigger["aria-expanded"]
    assert_selector "#mobile-nav a", text: "Sobre mí", visible: true

    trigger.click

    assert_equal "false", trigger["aria-expanded"]
    assert_no_selector "#mobile-nav a", text: "Sobre mí", visible: true
  end

  test "following a link from the open panel navigates and closes it" do
    resize_to_mobile
    visit root_path

    find("[data-nav-target='trigger']").click
    within("#mobile-nav") { click_link "Sobre mí" }

    assert_current_path about_path
    assert_no_selector "#mobile-nav a", text: "Sobre mí", visible: true
  end

  test "the desktop nav shows the links inline without a menu button" do
    visit root_path

    assert_selector "nav a", text: "Sobre mí", visible: true
    assert_no_selector "[data-nav-target='trigger']", visible: true
  end

  private
    def resize_to_mobile
      resize_window_to(*MOBILE_SCREEN)
    end

    def resize_to_desktop
      resize_window_to(*ApplicationSystemTestCase::SCREEN_SIZE)
    end

    def resize_window_to(width, height)
      page.driver.browser.manage.window.resize_to(width, height)
    end
end
