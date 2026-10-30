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

  test "offers to improve a sheet only when it already has items" do
    @user.connect_open_router!("sk-or-test")

    stub_singleton(OpenRouter::FreeModels, :all, -> { FREE_MODELS }) do
      get new_recommendation_url(sheet_id: sheets(:one))
      assert_select "input[name='recommendation[mode]'][value=improve]"

      get new_recommendation_url(sheet_id: sheets(:empty_workout))
      assert_select "input[name='recommendation[mode]']", false
    end
  end

  test "leaves the suggestion to a job and remembers the chosen model" do
    @user.connect_open_router!("sk-or-test")

    assert_enqueued_with(job: RecommendationJob, args: [ @user, "token", answer_params.except(:model).merge(split: "3").stringify_keys, nil ]) do
      post recommendation_url, params: { token: "token", recommendation: answer_params.merge(model: "b/free:free", split: "3") }
    end

    assert_response :accepted
    assert_equal "b/free:free", @user.reload.open_router_model
  end

  test "cannot recommend for someone else's sheet" do
    sign_in_as(users(:lazaro)).connect_open_router!("sk-or-test")

    post recommendation_url(sheet_id: sheets(:one)), params: { token: "token", recommendation: answer_params }

    assert_response :not_found
  end

  private

    def answer_params
      { kind: "workout", goal: "gain_muscle", activity_level: "moderately_active", dietary_preference: "none", model: "openrouter/free" }
    end
end
