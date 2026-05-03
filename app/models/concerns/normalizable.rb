module Normalizable
  extend ActiveSupport::Concern

  class_methods do
    def normalize(value)
      I18n.transliterate(value.to_s.strip)
    end

    def sanitize_search(value)
      ActiveRecord::Base.sanitize_sql_like(normalize(value))
    end
  end
end



