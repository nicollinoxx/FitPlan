module User::OpenRouter::Connectable
  extend ActiveSupport::Concern

  included do
    encrypts :open_router_key
  end

  def open_router_authorize_url(callback_url)
    OpenRouter::Pkce.new(signed_id(purpose: :open_router_connection, expires_in: 10.minutes)).authorize_url(callback_url)
  end

  def open_router_connected?
    open_router_key.present?
  end

  def connect_open_router!(key)
    update!(open_router_key: key)
  end

  def disconnect_open_router!
    update!(open_router_key: nil, open_router_model: nil)
  end

  def open_router_chat
    RubyLLM.context { |config| config.openrouter_api_key = open_router_key }.chat(model: open_router_model, provider: :openrouter, assume_model_exists: true)
  end

  # Asked of OpenRouter at most once a minute: the count only moves when a
  # suggestion is made, and that forgets it.
  def open_router_free_requests
    Rails.cache.fetch(open_router_free_requests_key, expires_in: 1.minute) do
      OpenRouter::Client.key(open_router_key)&.dig("free_model_daily_requests")
    end
  end

  def forget_open_router_free_requests
    Rails.cache.delete(open_router_free_requests_key)
  end

  def preferred_open_router_model
    open_router_model || OpenRouter::FreeModels::DEFAULT
  end

  private

    def open_router_free_requests_key
      "open_router/free_requests/#{id}"
    end
end
