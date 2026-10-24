module OpenRouter
  class Recommendation
    attr_reader :user, :sheet, :answers

    def initialize(user, answers:, sheet: nil)
      @user    = user
      @sheet   = sheet
      @answers = answers
    end

    def generate
      sheets = JSON.parse(content[/\{.*\}/m]).fetch("sheets")
      { sheets: sheet_types.map { |sheet_type| sheets.find { |sheet| sheet["sheet_type"] == sheet_type } } }
    end

    def sheet_types
      kind = sheet&.sheet_type || answers[:kind]
      kind == "both" ? %w[ workout diet ] : [ kind ]
    end

    private

      def content
        prompt = Prompt.new(self)

        user.open_router_chat
          .with_instructions(prompt.instructions)
          .with_provider_options(response_format: { type: "json_object" })
          .ask(prompt.question)
          .content
      end
  end
end
