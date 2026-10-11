module Diets
  class PositionsController < ApplicationController
    include SheetScoped
    before_action :set_diet

    def update
      @diet.update!(diet_params)
    end

    private

      def set_diet
        @diet = @sheet.diets.find(params[:diet_id])
      end

      def diet_params
        params.expect(diet: [ :position ])
      end
  end
end
