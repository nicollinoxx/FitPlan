module OpenRouter
  class Prompt
    include Recommendation::Restrictions

    delegate :user, :sheet, :answers, :sheet_types, to: :@recommendation

    def initialize(recommendation)
      @recommendation = recommendation
    end

    def instructions
      <<~PROMPT
        You are a certified personal trainer and sports nutritionist working inside FitPlan, a fitness planning app.
        Build a safe, realistic plan for the person described in the user message.

        Rules:
        - Reply with a single JSON object and nothing else: no markdown, no code fences, no comments.
        - Write every text value in #{language}.
        - Return exactly one sheet for each of these sheet types: #{sheet_types.join(", ")}.
        - A workout sheet has at most #{MAXIMUM_WORKOUTS} workouts; a diet sheet has at most #{MAXIMUM_DIETS} meals.
        - "interval" is the rest between series in seconds. "charge" is one of: #{CHARGES.join(", ")}.
        - Macronutrients are grams per meal. Calories are calculated by the app, do not send them.
        - Do not repeat anything listed in "existing"; complement it instead.
        - Respect the notes (injuries, equipment, schedule, allergies) over every other preference.

        JSON format:
        #{Recommendation::Format.for(sheet_types).to_json}
      PROMPT
    end

    def question
      context.to_json
    end

    private

      def context
        { answers: answers, profile: user.healthy_metric&.recommendation_profile, existing: existing }.compact_blank
      end

      def existing
        { workouts: sheet.workouts.pluck(:exercise), diets: sheet.diets.pluck(:meal) }.compact_blank if sheet
      end

      def language
        I18n.t("languages.#{I18n.locale}", locale: :en)
      end
  end
end
