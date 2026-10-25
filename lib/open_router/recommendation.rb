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
      return [ sheet.sheet_type ] if sheet

      case answers[:kind]
      when "workout" then workouts
      when "diet"    then %w[ diet ]
      else                workouts + %w[ diet ]
      end
    end

    # How many workout sheets a new plan is split into: A, B, C...
    def split
      answers[:split].to_i.clamp(Restrictions::SPLITS)
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

      def workouts
        Array.new(split, "workout")
      end

      def sheets(suggested)
        sheet_types.tally.flat_map do |sheet_type, count|
          suggested.select { |suggestion| suggestion["sheet_type"] == sheet_type }.first(count)
        end
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
