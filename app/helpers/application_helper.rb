module ApplicationHelper
  # Signing in through a provider runs its flow on another host, and Hotwire
  # Native hands another host to a Custom Tab. The tab keeps its cookies in the
  # browser rather than in the app's WebView, so the provider accepts the sign
  # in and the app still comes back signed out -- the button looks broken even
  # though the callback succeeded.
  #
  # Hidden in the native apps until they either sign in through the providers'
  # own SDKs, or the callback hands the session back over a verified App Link.
  # Turning it back on is this predicate alone: the buttons, the routes and the
  # credentials all stay where they are.
  def social_login_available?
    !turbo_native_app?
  end
end
