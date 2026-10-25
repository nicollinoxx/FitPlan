module OpenRouter
  class Recommendation
    module Restrictions
      MAXIMUM_WORKOUTS = 10
      MAXIMUM_DIETS    = 10

      KINDS               = %w[ workout diet both ].freeze
      GOALS               = %w[ lose_weight gain_muscle maintain_weight ].freeze
      ACTIVITY_LEVELS     = %w[ sedentary lightly_active moderately_active very_active ].freeze
      DIETARY_PREFERENCES = %w[ none vegetarian vegan keto paleo ].freeze
      CHARGES             = %w[ low medium high ].freeze
    end
  end
end
