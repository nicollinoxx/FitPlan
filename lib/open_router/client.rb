module OpenRouter
  class Client
    include HTTParty

    base_uri "https://openrouter.ai/api/v1"
    headers "Content-Type" => "application/json"

    def self.exchange_code(code:, verifier:)
      post("/auth/keys", body: { code: code, code_verifier: verifier, code_challenge_method: "S256" }.to_json).fetch("key")
    end

    def self.models
      get("/models")["data"]
    end

    def self.key(api_key)
      get("/key", headers: { "Authorization" => "Bearer #{api_key}" })["data"]
    end
  end
end
