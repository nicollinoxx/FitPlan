require "test_helper"

class RecommendationsControllerTest < ActionDispatch::IntegrationTest
  FREE_MODELS = [ { id: "openrouter/free", name: "Free Models Router" }, { id: "b/free:free", name: "B Free" } ]

  setup do
    @user = sign_in_as(users(:lazaro_nixon))
  end

  test "asks to connect OpenRouter before anything else" do
    get new_recommendation_url

    assert_response :success
    assert_select "a[href^='https://openrouter.ai/auth']"
    assert_select "#recommendation_form", false
  end

  test "lists only the free models once connected" do
    @user.connect_open_router!("sk-or-test")

    stub_singleton(OpenRouter::FreeModels, :all, -> { FREE_MODELS }) do
      get new_recommendation_url
    end

    assert_select "select[name='recommendation[model]'] option:not([value=''])", count: 2
    assert_select "input[name='recommendation[kind]'][type=radio]", count: 3
  end

  test "recommending for an existing sheet takes its type instead of asking" do
    @user.connect_open_router!("sk-or-test")

    stub_singleton(OpenRouter::FreeModels, :all, -> { FREE_MODELS }) do
      get new_recommendation_url(sheet_id: sheets(:two))
    end

    assert_select "input[name='recommendation[kind]'][type=hidden][value=diet]"
    assert_select "input[name='recommendation[kind]'][type=radio]", false
  end

  test "answers with the suggested sheets and remembers the chosen model" do
    @user.connect_open_router!("sk-or-test")
    answer = open_router_answer({ sheet_type: "workout", name: "Legs", workouts: [ { exercise: "Squat" } ] })

    stub_open_router_answer(answer) do |asked|
      post recommendation_url, params: { recommendation: answer_params.merge(model: "b/free:free") }

      assert_equal "b/free:free", asked.last[:model]
    end

    assert_response :success
    assert_equal "Legs", response.parsed_body.dig("sheets", 0, "name")
    assert_equal "b/free:free", @user.reload.open_router_model
  end

  test "cannot recommend for someone else's sheet" do
    sign_in_as(users(:lazaro)).connect_open_router!("sk-or-test")

    post recommendation_url(sheet_id: sheets(:one)), params: { recommendation: answer_params }

    assert_response :not_found
  end

  private

    def answer_params
      { kind: "workout", goal: "gain_muscle", activity_level: "moderately_active", dietary_preference: "none", model: "openrouter/free" }
    end
end
