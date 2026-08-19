module RankingsHelper
  def ranking_medal_class(position)
    case position
    when 1 then 'text-warning'
    when 2 then 'text-secondary'
    when 3 then 'text-orange'
    else        'text-muted'
    end
  end
end
