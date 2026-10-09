require "test_helper"

class LocalesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:lazaro_nixon)
  end

  test "switching the language follows on the next request" do
    sign_in_as(@user)
    patch set_locale_url("pt")

    assert_redirected_to root_url
    assert_equal "pt", cookies[:locale]

    get sheets_url
    assert_select "h1", text: I18n.t("sheets.index.title", locale: :pt)
  end

  test "the apps reload the page the language was picked on instead of going back to it" do
    sign_in_as(@user)
    patch set_locale_url("pt"), headers: { "Referer" => identity_settings_url, "User-Agent" => "Hotwire Native iOS" }

    assert_redirected_to identity_settings_url
  end

  test "nothing is published until a language is picked" do
    sign_in_as(@user)
    get sheets_url

    assert_nil cookies[:locale]
  end

  test "picking a language signed out publishes it too" do
    patch set_locale_url("pt")

    assert_equal "pt", cookies[:locale]
  end

  test "an unknown language is ignored" do
    sign_in_as(@user)
    patch set_locale_url("pt")
    patch set_locale_url("xx")

    assert_equal "pt", @user.reload.locale
  end

  test "signing in somewhere else brings the language along" do
    sign_in_as(@user)
    patch set_locale_url("pt")
    assert_equal "pt", @user.reload.locale

    reset!
    sign_in_as(@user)
    get sheets_url

    assert_select "h1", text: I18n.t("sheets.index.title", locale: :pt)
    assert_equal "pt", cookies[:locale]
  end

  test "the account wins over a language picked before signing in" do
    @user.update!(locale: "pt")

    patch set_locale_url("en")
    sign_in_as(@user)
    get sheets_url

    assert_select "h1", text: I18n.t("sheets.index.title", locale: :pt)
  end

  test "signed out, the language is remembered on the browser alone" do
    patch set_locale_url("pt")

    get sign_in_url
    assert_select "input[value=?]", I18n.t("sessions.new.submit", locale: :pt)
    assert_nil @user.reload.locale
  end

  test "without a pick, the device still decides" do
    get welcome_url, headers: { "Accept-Language" => "pt-BR,pt;q=0.9" }

    assert_select "a", text: I18n.t("welcome.sign_in", locale: :pt)
    assert_nil cookies[:locale]
  end

  test "a tampered cookie falls back instead of being trusted" do
    cookies[:locale] = "klingon"

    get sign_in_url

    assert_select "input[value=?]", I18n.t("sessions.new.submit", locale: I18n.default_locale)
  end
end
