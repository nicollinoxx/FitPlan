module ChartsHelper
  # Renders a Chartkick chart through the "chart" Stimulus controller, which
  # holds the shared styling and redraws it when the color mode changes.
  #
  # `accents` names Bootstrap colors ("success", "orange"), one per series, so a
  # chart asks for a place in the palette instead of for a literal color.
  def chart_tag(type, data, accents: %w[success], height: "300px", **options)
    tag.div style: "height: #{height}", data: {
      controller: "chart",
      chart_type_value: type,
      chart_data_value: data.to_json,
      chart_accents_value: accents.to_json,
      chart_options_value: options.to_json
    }
  end
end
