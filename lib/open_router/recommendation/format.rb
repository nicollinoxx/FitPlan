module OpenRouter
  class Recommendation
    module Format
      ITEMS = {
        "workout" => { workouts: [ { exercise: "Back squat", series: 4, repetitions: "8-10", interval: 90, charge: "medium" } ] },
        "diet"    => { diets: [ { meal: "Breakfast", description: "Foods and portions", protein_g: 30, carbohydrate_g: 45, fat_g: 12 } ] }
      }.freeze

      def self.for(sheet_types)
        { sheets: sheet_types.map { |sheet_type| { sheet_type: sheet_type, name: "short sheet name", description: "one sentence about the plan" }.merge(ITEMS[sheet_type]) } }
      end
    end
  end
end
