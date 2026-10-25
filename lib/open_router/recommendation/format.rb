module OpenRouter
  class Recommendation
    module Format
      FIELDS = {
        "workout" => %w[ exercise series repetitions interval charge ],
        "diet"    => %w[ meal description protein_g carbohydrate_g fat_g ]
      }.freeze

      ITEMS = {
        "workout" => { exercise: "Back squat", series: 4, repetitions: "8-10", interval: 90, charge: "medium" },
        "diet"    => { meal: "Breakfast", description: "Foods and portions", protein_g: 30, carbohydrate_g: 45, fat_g: 12 }
      }.freeze

      def self.for(sheet_types)
        { sheets: sheet_types.map { |sheet_type| { sheet_type: sheet_type, name: "short sheet name", description: "one sentence about the plan", "#{sheet_type}s": [ ITEMS[sheet_type] ] } } }
      end

      def self.changes(sheet_type)
        { changes: [ ITEMS[sheet_type].merge(id: 1, reason: "short reason for the change") ] }
      end

      # A workout or a meal as the model reads it, and as the preview shows it before a change.
      def self.item(record)
        record.slice("id", *FIELDS[record.sheet.sheet_type]).transform_values do |value|
          case value
          when ActionText::RichText then value.to_plain_text
          when BigDecimal           then value.to_f
          else                           value
          end
        end
      end
    end
  end
end
