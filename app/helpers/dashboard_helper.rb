module DashboardHelper
  def period_options
    %w[day week month year].map do |time|
      [t(".filters.period.#{time}"), time]
    end
  end
end
