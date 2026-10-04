require "test_helper"

class LocalesControllerTest < ActionDispatch::IntegrationTest
  test "picking a language holds from the next request on" do
    get set_locale_url("pt")

    assert_redirected_to root_url
    assert_equal "pt", cookies[:locale]

    get sign_in_url
    assert_select "input[value=?]", I18n.t("sessions.new.submit", locale: :pt)
  end

  test "an unknown language is ignored" do
    get set_locale_url("pt")
    get set_locale_url("xx")

    assert_equal "pt", cookies[:locale]
  end

  test "a tampered cookie falls back instead of being trusted" do
    cookies[:locale] = "klingon"

    get sign_in_url

    assert_select "input[value=?]", I18n.t("sessions.new.submit", locale: I18n.default_locale)
  end

  test "without a pick, the device still decides" do
    get welcome_url, headers: { "Accept-Language" => "pt-BR,pt;q=0.9" }

    assert_select "a", text: I18n.t("welcome.sign_in", locale: :pt)
    assert_nil cookies[:locale]
  end
end
