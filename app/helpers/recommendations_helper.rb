module RecommendationsHelper
  KIND_STYLES = { "workout" => %w[ success bi-heart-pulse ], "diet" => %w[ orange bi-egg-fried ], "both" => %w[ primary bi-list-ul ] }.freeze
  MODE_ICONS  = { "add" => "bi-plus-lg", "improve" => "bi-magic" }.freeze

  def recommendation_mode_label(form, mode, sheet)
    form.label "mode_#{mode}", class: "btn btn-outline-body btn-checked-#{sheet_color(sheet)}" do
      tag.i(class: "bi #{MODE_ICONS.fetch(mode)} me-1") + t("recommendations.form.modes.#{mode}")
    end
  end

  def recommendation_about
    metrics = Current.user.healthy_metric ? t("recommendations.form.about.metrics") : t("recommendations.form.about.no_metrics")
    language = t("recommendations.form.about.language", language: t("languages.#{I18n.locale}"))

    "#{metrics} #{language}"
  end

  def recommendation_change_labels
    { exercise: t("workouts.form.label.exercise"), series: t("series"), repetitions: t("repetitions"), interval: t("interval"), charge: t("charge"),
      meal: t("diets.form.label.meal"), description: t("diets.form.label.description"), protein_g: t("proteins"), carbohydrate_g: t("carbohydrates"), fat_g: t("fats") }
  end

  def recommendation_kind_label(form, kind)
    color, icon = KIND_STYLES.fetch(kind)

    form.label "kind_#{kind}", class: "btn btn-outline-body btn-checked-#{color}" do
      tag.i(class: "bi #{icon} me-1") + t("recommendations.form.kinds.#{kind}")
    end
  end
end
