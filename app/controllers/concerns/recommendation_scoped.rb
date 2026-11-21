# Saving a suggestion goes through the Recommendation it came from, so the same
# suggestion is only ever saved once.
module RecommendationScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_recommendation, only: :create
  end

  private

    def set_recommendation
      @recommendation = Current.user.recommendations.find_by!(token: params.expect(:token))
    end
end
