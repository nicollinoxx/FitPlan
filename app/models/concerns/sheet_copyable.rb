module SheetCopyable
  extend ActiveSupport::Concern

  def copy_sheet(recipient)
    sheet_copy = recipient.sheets.build(sheet_params)
    return unless sheet_copy.save

    copy_workouts(sheet_copy) if workout?
    copy_diets(sheet_copy) if diet?
  end

  private

  def copy_workouts(sheet_copy)
    workouts.find_each do |workout|
      new_workout = sheet_copy.workouts.create(workout.attributes.except("id", "created_at", "updated_at"))
      new_workout.video.attach(workout.video.blob)
    end
  end

  def copy_diets(sheet_copy)
    diets.find_each do |diet|
      sheet_copy.diets.create(assocation_attributes(diet).merge(description: diet.description.body.to_html))
    end
  end

  def sheet_params
    attributes.except("id", "created_at", "updated_at").merge(copy: true)
  end
end
