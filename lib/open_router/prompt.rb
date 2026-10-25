module OpenRouter
  class Prompt
    include Recommendation::Restrictions

    delegate :user, :sheet, :answers, :sheet_types, :improving?, to: :@recommendation

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
        #{improving? ? improve_rules : add_rules}
        - "interval" is the rest between series in seconds. "charge" is one of: #{CHARGES.join(", ")}.
        - Macronutrients are grams per meal. Calories are calculated by the app, do not send them.
        - Respect the notes (injuries, equipment, schedule, allergies) over every other preference.

        JSON format:
        #{(improving? ? Recommendation::Format.changes(sheet.sheet_type) : Recommendation::Format.for(sheet_types)).to_json}
      PROMPT
    end

    def question
      context.to_json
    end

    private

      def context
        { answers: answers, profile: user.healthy_metric&.recommendation_profile, existing: existing }.compact_blank
      end

      def add_rules
        <<~RULES.strip
          - Return exactly one sheet for each of these sheet types: #{sheet_types.join(", ")}.
          - A workout sheet has at most #{MAXIMUM_WORKOUTS} workouts; a diet sheet has at most #{MAXIMUM_DIETS} meals.
          - Do not repeat anything listed in "existing"; complement it instead.
        RULES
      end

      def improve_rules
        <<~RULES.strip
          - Improve what is listed in "existing" instead of adding anything new.
          - Return only the items worth changing, each with its unchanged "id", every field with its new value and a short "reason".
          - Never invent an id. Return an empty "changes" list when nothing should change.
        RULES
      end

      def existing
        { "#{sheet.sheet_type}s": sheet.items.positioned.map { |item| Recommendation::Format.item(item) } } if sheet
      end

      def language
        I18n.t("languages.#{I18n.locale}", locale: :en)
      end
  end
end
