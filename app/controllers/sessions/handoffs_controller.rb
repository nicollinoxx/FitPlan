# Opens in the Custom Tab: keeps the app's code for the callback, then starts the
# provider's flow, which OmniAuth only accepts as a POST from this page. The tab
# has none of the app's cookies, so it also takes the app's language from the link.
class Sessions::HandoffsController < ApplicationController
  skip_before_action :authenticate

  def show
    session[:session_handoff] = params.expect(:code)
    @provider = params[:provider]

    speak_the_apps_language if has_locale_in_params?
  end

  private

    def speak_the_apps_language
      remember_locale
      I18n.locale = params[:locale]
    end
end
