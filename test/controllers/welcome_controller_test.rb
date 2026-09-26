require "test_helper"

class WelcomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get welcome_url
    assert_response :success
  end

  test "follows the device language" do
    get welcome_url, headers: { "Accept-Language" => "pt-BR,pt;q=0.9" }
    assert_select "a", text: "Entrar"

    get welcome_url, headers: { "Accept-Language" => "en-US,en;q=0.9" }
    assert_select "a", text: "Sign In"
  end

  test "falls back to the default language" do
    get welcome_url, headers: { "Accept-Language" => "fr-FR" }
    assert_select "a", text: I18n.t("welcome.sign_in", locale: I18n.default_locale)
  end
end
