module RecommendationsHelper
  KIND_STYLES = { "workout" => %w[ success bi-heart-pulse ], "diet" => %w[ orange bi-egg-fried ], "both" => %w[ primary bi-list-ul ] }.freeze

  def recommendation_kind_label(form, kind)
    color, icon = KIND_STYLES.fetch(kind)

    form.label "kind_#{kind}", class: "btn btn-outline-body btn-checked-#{color}" do
      tag.i(class: "bi #{icon} me-1") + t("recommendations.form.kinds.#{kind}")
    end
  end
end
