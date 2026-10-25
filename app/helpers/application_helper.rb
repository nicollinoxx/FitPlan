module ApplicationHelper
  # Signing in through a provider runs on another host, and Google refuses to run
  # in a WebView. In the browser the button posts straight to OmniAuth. In the
  # native apps it links to the handoff page, which the apps open in a Custom Tab
  # (see SessionHandoff for how the session finds its way back to the WebView).
  def social_sign_in_button(provider, label, icon:, code:)
    classes = "btn btn-outline-body w-100 d-flex align-items-center justify-content-center gap-2"
    content = tag.i(class: "bi bi-#{icon}") + " " + label

    if turbo_native_app?
      link_to content, session_handoff_path(provider, code: code, locale: I18n.locale), class: classes, aria: { label: t("sessions.new.#{icon}") }
    else
      button_to content, "/auth/#{provider}", method: :post, data: { turbo: false }, class: classes, aria: { label: t("sessions.new.#{icon}") }
    end
  end
end
