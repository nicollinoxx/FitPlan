require "test_helper"

class RecommendationJobTest < ActiveJob::TestCase
  include ActionCable::TestHelper

  setup do
    @user = users(:lazaro_nixon)
    @user.update!(open_router_key: "sk-or-test", open_router_model: "openrouter/free")
  end

  test "sends the suggestion to the page that asked, by its token" do
    answer = open_router_answer({ sheet_type: "workout", name: "Legs", workouts: [ { exercise: "Squat" } ] })

    stub_open_router_answer(answer) do
      assert_broadcasts(RecommendationChannel.broadcasting_for(@user), 1) do
        RecommendationJob.perform_now(@user, "token", { "kind" => "workout" })
      end
    end

    message = broadcasts(RecommendationChannel.broadcasting_for(@user)).last
    assert_equal "token", JSON.parse(message)["token"]
    assert_equal "Legs", JSON.parse(message).dig("recommendation", "sheets", 0, "name")
  end

  test "tells the page when the model could not answer" do
    stub_open_router_answer("not json") do
      RecommendationJob.perform_now(@user, "token", { "kind" => "workout" })
    end

    message = JSON.parse(broadcasts(RecommendationChannel.broadcasting_for(@user)).last)
    assert_equal({ "token" => "token", "failed" => true }, message)
  end

  test "writes the suggestion in the language of the request that asked for it" do
    stub_open_router_answer(open_router_answer({ sheet_type: "workout", name: "Legs" })) do |asked|
      I18n.with_locale(:en) { RecommendationJob.perform_later(@user, "token", { "kind" => "workout" }) }
      I18n.with_locale(:pt) { perform_enqueued_jobs }

      assert_includes asked.last[:instructions], "Write every text value in English"
    end
  end
end
