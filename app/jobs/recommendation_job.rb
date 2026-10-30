# Free models can take a minute or two to answer. Asking them here keeps the
# web threads free; the page that asked listens on RecommendationChannel for
# the token it sent and gets either the suggestion or word that it failed.
class RecommendationJob < ApplicationJob
  queue_as :default

  def perform(user, token, answers, sheet = nil)
    recommendation = OpenRouter::Recommendation.new(user, sheet: sheet, answers: answers).generate
    RecommendationChannel.broadcast_to(user, token: token, recommendation: recommendation)
  rescue StandardError => error
    Rails.error.report(error)
    RecommendationChannel.broadcast_to(user, token: token, failed: true)
  end
end
