module SheetCopyable
  extend ActiveSupport::Concern

  def copy_sheet(recipient)
    sheet_copy = recipient.sheets.build(sheet_params)
    return unless sheet_copy.save

    if workout?
      copy_workouts(sheet_copy)
    elsif diet?
      copy_diets(sheet_copy) if diet?
    end
  end

  private

  def copy_workouts(sheet_copy)
    workouts.find_each do |workout|
      new_workout = sheet_copy.workouts.create(copy_item_attributes(workout))
      new_workout.video.attach(workout.video.blob)
    end
  end

  def copy_diets(sheet_copy)
    diets.find_each do |diet|
      sheet_copy.diets.create(copy_item_attributes(diet).merge(description: diet.description.body.to_html))
    end
  end

  def sheet_params
    attributes.except("id", "created_at", "updated_at").merge(copy: true)
  end

  def copy_item_attributes(item)
    item.attributes.except("id", "created_at", "updated_at")
  end
end
