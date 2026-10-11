module Sheets
  class PositionsController < ApplicationController
    include SheetScoped

    def update
      @sheet.update!(sheet_params)
    end

    private

      def sheet_params
        params.expect(sheet: [ :position ])
      end
  end
end
