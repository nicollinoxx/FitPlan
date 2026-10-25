require "test_helper"

class OpenRouter::FreeModelsTest < ActiveSupport::TestCase
  MODELS = [
    { "id" => "z/paid", "name" => "Paid", "pricing" => { "prompt" => "0.000001", "completion" => "0.000002" }, "architecture" => { "output_modalities" => [ "text" ] } },
    { "id" => "b/free:free", "name" => "B Free", "pricing" => { "prompt" => "0", "completion" => "0" }, "architecture" => { "output_modalities" => [ "text" ] } },
    { "id" => "a/audio:free", "name" => "Audio", "pricing" => { "prompt" => "0", "completion" => "0" }, "architecture" => { "output_modalities" => [ "text", "audio" ] } },
    { "id" => "openrouter/free", "name" => "A Router", "pricing" => { "prompt" => "0", "completion" => "0" }, "architecture" => { "output_modalities" => [ "text" ] } }
  ]

  test "lists only free text models, sorted by name" do
    stub_singleton(OpenRouter::Client, :models, -> { MODELS }) do
      assert_equal [ { id: "openrouter/free", name: "A Router" }, { id: "b/free:free", name: "B Free" } ], OpenRouter::FreeModels.all
    end
  end

  test "caches the list so the form does not wait on OpenRouter every time" do
    calls = 0

    with_memory_cache do
      stub_singleton(OpenRouter::Client, :models, -> { calls += 1; MODELS }) do
        2.times { OpenRouter::FreeModels.all }
      end
    end

    assert_equal 1, calls
  end
end
