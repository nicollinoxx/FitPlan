module Sheet::Copyable
  def copy_sheet(recipient)
    ActiveRecord::Base.transaction do
      sheet_copy = recipient.sheets.build(sheet_params)

      if workout?
        copy_workouts(sheet_copy)
        raise ActiveRecord::Rollback if sheet_copy.workouts.empty?
      elsif diet?
        copy_diets(sheet_copy)
        raise ActiveRecord::Rollback if sheet_copy.diets.empty?
      end

      sheet_copy.save!
    end
  end

  private

  def copy_workouts(sheet_copy)
    workouts.find_each(batch_size: 25) do |workout|
      new_workout = sheet_copy.workouts.build(item_attributes(workout))
      new_workout.video.attach(workout.video.blob) if workout.video.attached?
    end
  end

  def copy_diets(sheet_copy)
    diets.find_each(batch_size: 25) do |diet|
      sheet_copy.diets.build(item_attributes(diet).merge(description: diet.description&.body&.to_html))
    end
  end

  def sheet_params
    attributes.except("id", "created_at", "updated_at").merge(copy: true)
  end

  def item_attributes(item)
    item.attributes.except("id", "created_at", "updated_at")
  end
end
