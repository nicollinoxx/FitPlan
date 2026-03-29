module Diets
  class CompletionsController < ApplicationController
    include SheetScoped
    before_action :set_diet

    def create
      @completion = @sheet.completions.create!(user: Current.user, diet: @diet)
      refresh_or_redirect_to sheet_diets_url(@sheet), notice: congratulations_notice
    end

    def destroy
      @sheet.completions.current_round(@sheet).find_by!(diet: @diet).destroy!
      refresh_or_redirect_to sheet_diets_url(@sheet)
    end

    private

      def set_diet
        @diet = @sheet.diets.find(params[:diet_id])
      end

      def congratulations_notice
        t('notice.sheet_completion.create') if @completion.sheet_completed?
      end
  end
end
