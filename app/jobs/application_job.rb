class ApplicationJob < ActiveJob::Base
  retry_on StandardError, wait: ->(executions) { executions * 3.minutes }, attempts: 5


  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
end
