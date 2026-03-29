module Sheets
  class CompletionsController < ApplicationController
    include SheetScoped

    def create
      Current.user.completions.create!(completion_params.merge(sheet: @sheet, completed_at: Time.current))
      refresh_or_redirect_to redirect_fallback
    end

    def destroy
      Current.user.completions.find(params.expect(:id)).destroy!
      refresh_or_redirect_to redirect_fallback
    end

    private

      def completion_params
        params.expect(completion: [ :workout_id, :diet_id ])
      end

      def redirect_fallback
        @sheet.workout? ? sheet_workouts_url(@sheet) : sheet_diets_url(@sheet)
      end
  end
end
