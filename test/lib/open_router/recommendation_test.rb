require "test_helper"

class OpenRouter::RecommendationTest < ActiveSupport::TestCase
  setup do
    @user = users(:lazaro_nixon)
    @user.update!(open_router_key: "sk-or-test", open_router_model: "openrouter/free")
  end

  test "forgets the cached free requests once the model was asked, even when it failed" do
    with_memory_cache do |cache|
      cache.write("open_router/free_requests/#{@user.id}", { "remaining" => 47 })

      stub_open_router_answer("not json") do
        assert_raises(StandardError) { recommendation(kind: "workout").generate }
      end

      assert_not cache.exist?("open_router/free_requests/#{@user.id}")
    end
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
      assert_equal sheets(:one).workouts.positioned.map { |workout| workout.slice("id", "exercise", "series", "repetitions", "interval", "charge") }, question.dig("existing", "workouts")
    end
  end

  test "asks for the answer in the user's language" do
    stub_open_router_answer(open_router_answer({ sheet_type: "diet", name: "Dieta" })) do |asked|
      I18n.with_locale(:pt) { recommendation(kind: "diet").generate }

      assert_includes asked.last[:instructions], "Write every text value in Portuguese"
    end
  end

  test "proposes changes to the existing items, next to how they are now" do
    workout = workouts(:one)
    answer  = { changes: [ { id: workout.id, exercise: "Front squat", series: 5, repetitions: "5", interval: 120, charge: "high", reason: "More strength" } ] }.to_json

    stub_open_router_answer(answer) do |asked|
      changes = OpenRouter::Recommendation.new(@user, sheet: sheets(:one), answers: { mode: "improve" }).generate[:changes]

      assert_includes asked.last[:instructions], "Improve what is listed"
      assert_equal [ workout.id ], changes.pluck(:id)
      assert_equal workout.exercise, changes.first[:before]["exercise"]
      assert_equal "Front squat", changes.first[:after]["exercise"]
      assert_equal "More strength", changes.first[:reason]
    end
  end

  test "leaves out changes to items the sheet does not have" do
    answer = { changes: [ { id: workouts(:one).id, series: 5 }, { id: workouts(:two).id, series: 2 }, { id: 0, series: 1 } ] }.to_json

    stub_open_router_answer(answer) do
      assert_equal [ workouts(:one).id ], OpenRouter::Recommendation.new(@user, sheet: sheets(:one), answers: { mode: "improve" }).generate[:changes].pluck(:id)
    end
  end

  test "keeps only the fields that really change" do
    workout = workouts(:one)
    answer  = { changes: [ { id: workout.id, exercise: workout.exercise, series: workout.series + 1 }, { id: workouts(:another).id, exercise: workouts(:another).exercise } ] }.to_json

    stub_open_router_answer(answer) do
      changes = OpenRouter::Recommendation.new(@user, sheet: sheets(:one), answers: { mode: "improve" }).generate[:changes]

      assert_equal [ workout.id ], changes.pluck(:id)
      assert_equal({ "series" => workout.series + 1 }, changes.first[:after])
    end
  end

  private

    def recommendation(kind:)
      OpenRouter::Recommendation.new(@user, answers: { kind: kind, goal: "gain_muscle" })
    end
end
