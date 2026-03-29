module Diets
  class CompletionsController < ApplicationController
    include SheetScoped
    before_action :set_diet

    def create
      @sheet.completions.create!(user: Current.user, diet: @diet)
      refresh_or_redirect_to sheet_diets_url(@sheet)
    end

    def destroy
      @sheet.completions.current_round(@sheet).find_by!(diet: @diet).destroy!
      refresh_or_redirect_to sheet_diets_url(@sheet)
    end

    private

      def set_diet
        @diet = @sheet.diets.find(params[:diet_id])
      end
  end
end
