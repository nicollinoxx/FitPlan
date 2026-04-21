module Diets
  class CompletionsController < ApplicationController
    include SheetScoped
    before_action :set_diet

    def create
      @sheet.completions.today.find_or_create_by!(diet: @diet)
      redirect_to sheet_diets_url(@sheet)
    end

    def destroy
      @sheet.completions.today.find_by!(diet: @diet).destroy!
      redirect_to sheet_diets_url(@sheet)
    end

    private

      def set_diet
        @diet = @sheet.diets.find(params[:diet_id])
      end
  end
end
