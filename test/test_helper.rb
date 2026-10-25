ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def sign_in_as(user)
    post(sign_in_url, params: { email: user.email, password: "Secret1*3*5*" }); user
  end

  def stub_uri_open(file)
    original = URI.method(:open)
    URI.define_singleton_method(:open) { |*| file }
    yield
  ensure
    URI.define_singleton_method(:open, original)
  end

  def stub_singleton(object, name, implementation)
    original = object.method(name)
    object.define_singleton_method(name, &implementation)
    yield
  ensure
    object.define_singleton_method(name, original)
  end

  def stub_open_router_answer(content)
    asked = []
    RubyLLM::Chat.alias_method :original_ask, :ask
    RubyLLM::Chat.define_method(:ask) { |question| asked << { model: model.id, instructions: messages.first.content, question: question }; RubyLLM::Message.new(role: :assistant, content: content) }
    yield asked
  ensure
    RubyLLM::Chat.alias_method :ask, :original_ask
    RubyLLM::Chat.remove_method :original_ask
  end

  def open_router_answer(*sheets)
    "```json\n#{{ sheets: sheets }.to_json}\n```"
  end

  def with_rate_limit_exceeded
    store = ActionController::Base.cache_store
    store.define_singleton_method(:increment) { |*| Float::INFINITY }
    yield
  ensure
    store.singleton_class.remove_method(:increment)
  end

  def with_memory_cache
    original = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    yield Rails.cache
  ensure
    Rails.cache = original
  end
end
