module OpenRouter
  # The flow keeps nothing in the session: in the native apps it runs in a Custom
  # Tab, which has none of the WebView's cookies. The state carries who is
  # connecting, and the verifier is derived from it with the app's secret, so it
  # is never stored nor sent anywhere.
  class Pkce
    AUTHORIZE_URL = "https://openrouter.ai/auth".freeze

    attr_reader :state

    def initialize(state)
      @state = state
    end

    def verifier
      OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, state)
    end

    def authorize_url(callback_url)
      query = { callback_url: callback_url, code_challenge: challenge, code_challenge_method: "S256", state: state }
      "#{AUTHORIZE_URL}?#{query.to_query}"
    end

    private

      def challenge
        Base64.urlsafe_encode64(Digest::SHA256.digest(verifier), padding: false)
      end
  end
end
