module OpenRouter
  class Pkce
    AUTHORIZE_URL = "https://openrouter.ai/auth".freeze

    attr_reader :verifier, :state

    def initialize(verifier: SecureRandom.urlsafe_base64(64), state: SecureRandom.urlsafe_base64(24))
      @verifier = verifier
      @state = state
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
