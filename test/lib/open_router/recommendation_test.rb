require "test_helper"

class OpenRouter::RecommendationTest < ActiveSupport::TestCase
  setup do
    @user = users(:lazaro_nixon)
    @user.update!(open_router_key: "sk-or-test", open_router_model: "openrouter/free")
  end

  test "asks for one sheet of each requested type" do
    assert_equal %w[ workout ], recommendation(kind: "workout").sheet_types
    assert_equal %w[ diet ], recommendation(kind: "diet").sheet_types
    assert_equal %w[ workout diet ], recommendation(kind: "both").sheet_types
  end

  test "an existing sheet decides the type" do
    assert_equal %w[ diet ], OpenRouter::Recommendation.new(@user, sheet: sheets(:two), answers: { kind: "both" }).sheet_types
  end

  test "reads the sheets out of a fenced answer, in the requested order" do
    answer = open_router_answer({ sheet_type: "diet", name: "Diet", diets: [] }, { sheet_type: "workout", name: "Workout", workouts: [] })

    stub_open_router_answer(answer) do
      assert_equal %w[ Workout Diet ], recommendation(kind: "both").generate[:sheets].pluck("name")
    end
  end

  test "leaves out sheets that were not asked for" do
    answer = open_router_answer({ sheet_type: "workout", name: "Workout" }, { sheet_type: "diet", name: "Diet" })

    stub_open_router_answer(answer) do
      assert_equal %w[ Workout ], recommendation(kind: "workout").generate[:sheets].pluck("name")
    end
  end

  test "asks the user's model with the answers, the health profile and the existing items" do
    stub_open_router_answer(open_router_answer({ sheet_type: "workout", name: "Workout" })) do |asked|
      OpenRouter::Recommendation.new(@user, sheet: sheets(:one), answers: { goal: "gain_muscle" }).generate
      question = JSON.parse(asked.last[:question])

      assert_equal "openrouter/free", asked.last[:model]
      assert_equal "gain_muscle", question.dig("answers", "goal")
      assert_equal "male", question.dig("profile", "gender")
      assert_equal sheets(:one).workouts.pluck(:exercise), question.dig("existing", "workouts")
    end
  end

  test "asks for the answer in the user's language" do
    stub_open_router_answer(open_router_answer({ sheet_type: "diet", name: "Dieta" })) do |asked|
      I18n.with_locale(:pt) { recommendation(kind: "diet").generate }

      assert_includes asked.last[:instructions], "Write every text value in Portuguese"
    end
  end

  private

    def recommendation(kind:)
      OpenRouter::Recommendation.new(@user, answers: { kind: kind, goal: "gain_muscle" })
    end
end
