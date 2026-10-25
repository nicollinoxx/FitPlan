module OpenRouter
  module FreeModels
    DEFAULT = "openrouter/free".freeze

    extend self

    def all
      Rails.cache.fetch("open_router/free_models", expires_in: 1.hour) do
        Client.models.select { free?(it) && text_only?(it) }.map { { id: it["id"], name: it["name"] } }.sort_by { it[:name] }
      end
    end

    private

      def free?(model)
        model.dig("pricing", "prompt").to_d.zero? && model.dig("pricing", "completion").to_d.zero?
      end

      def text_only?(model)
        model.dig("architecture", "output_modalities") == [ "text" ]
      end
  end
end
