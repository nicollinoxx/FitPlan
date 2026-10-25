module OpenRouter
  class Recommendation
    attr_reader :user, :sheet, :answers

    def initialize(user, answers:, sheet: nil)
      @user    = user
      @sheet   = sheet
      @answers = answers
    end

    def generate
      json = JSON.parse(content[/\{.*\}/m])
      improving? ? { changes: changes(json.fetch("changes")) } : { sheets: sheets(json.fetch("sheets")) }
    end

    def sheet_types
      kind = sheet&.sheet_type || answers[:kind]
      kind == "both" ? %w[ workout diet ] : [ kind ]
    end

    def improving?
      sheet.present? && answers[:mode] == "improve"
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

      def sheets(suggested)
        sheet_types.map { |sheet_type| suggested.find { |suggestion| suggestion["sheet_type"] == sheet_type } }
      end

      def changes(proposed)
        proposed.filter_map do |change|
          item   = sheet.items.find_by(id: change["id"]) or next
          before = Format.item(item)
          after  = change.slice(*Format::FIELDS[sheet.sheet_type]).reject { |field, value| value.to_s == before[field].to_s }

          { id: item.id, reason: change["reason"], before: before, after: after } if after.any?
        end
      end
  end
end
