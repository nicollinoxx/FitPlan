class Sheets::CopySheetContentJob < ApplicationJob
  queue_as :default

  def perform(original_sheet_id, copy_sheet_id)
    @original_sheet = Sheet.find(original_sheet_id)
    @copy_sheet = Sheet.find(copy_sheet_id)

    build_workouts if @original_sheet.workout?
    build_diets if @original_sheet.diet?
  end

  private
    def build_workouts
      @original_sheet.workouts.find_each do |item|
        @copy_sheet.workouts.create!(copy_item_attributes(item))
      end
    end

    def build_diets
      @original_sheet.diets.find_each do |item|
        @copy_sheet.diets.create!(copy_item_attributes(item))
      end
    end

    def copy_item_attributes(item)
      item.attributes.except("id", "created_at", "updated_at")
    end
end
