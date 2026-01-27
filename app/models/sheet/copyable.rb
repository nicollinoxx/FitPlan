module Sheet::Copyable
  def copy_to(recipient)
    return true unless workouts.exists? || diets.exists?

    ActiveRecord::Base.transaction do
      copy = recipient.sheets.create!(attributes_for_copy)
      workout? ? copy_workouts_to(copy) : copy_diets_to(copy)

      raise ActiveRecord::RecordInvalid.new(copy) unless copy.workouts.exists? || copy.diets.exists?
    end

    true
  end

  private

  def copy_workouts_to(copy)
    workouts.find_each(batch_size: 5) do |workout|
      item = copy.workouts.create!(copy_item_attributes(workout))
      item.video.attach(workout.video.blob) if workout.video.attached?
    end
  end

  def copy_diets_to(copy)
    diets.find_each(batch_size: 5) do |diet|
      copy.diets.create!(copy_item_attributes(diet).merge(description: diet.description&.body&.to_s))
    end
  end

  def copy_item_attributes(item) = item.attributes.except("id", "created_at", "updated_at")
  def attributes_for_copy        = attributes.except("id", "created_at", "updated_at").merge(copy: true)
end
