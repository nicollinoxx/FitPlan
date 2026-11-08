require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400] do |options|
    options.add_preference(:intl, accept_languages: I18n.default_locale.to_s)
  end

  def t(...)
    I18n.t(...)
  end

  def sign_in_as(user)
    visit sign_in_url
    fill_in :email, with: user.email
    fill_in :password, with: "Secret1*3*5*"
    click_on t("sessions.new.submit")

    assert_selector "h1", text: t("sheets.index.title")
    user
  end

  def confirm_dialog
    assert_selector "dialog[open]", visible: true

    within "dialog[open]" do
      click_on t("confirm")
    end
  end
end
