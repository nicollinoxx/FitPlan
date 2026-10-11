module Positionable
  extend ActiveSupport::Concern

  included do
    class_attribute :position_scope_key

    scope :positioned, -> { order(:position, :id) }

    before_create  :place_last
    before_update  :make_room_for_new_position, if: :will_save_change_to_position?
    after_destroy  :close_gap
  end

  class_methods do
    def positioned_within(association)
      self.position_scope_key = reflect_on_association(association).foreign_key
    end
  end

  private

    def place_last
      self.position = position_siblings.maximum(:position).to_i + 1
    end

    def make_room_for_new_position
      from, to = position_change_to_be_saved
      siblings = position_siblings.where.not(id: id)

      if to < from
        siblings.where(position: to...from).update_all("position = position + 1")
      else
        siblings.where(position: (from + 1)..to).update_all("position = position - 1")
      end
    end

    def close_gap
      position_siblings.where("position > ?", position).update_all("position = position - 1")
    end

    def position_siblings
      self.class.where(position_scope_key => self[position_scope_key])
    end
end
