module Sheets
  class CompletionsController < ApplicationController
    include SheetScoped
    include ActionView::RecordIdentifier

    def create
      @sheet.complete!
      refresh_sheet_card
    end

    def destroy
      @sheet.uncomplete!
      refresh_sheet_card
    end

    private

    def refresh_sheet_card
      render turbo_stream: turbo_stream.replace("#{dom_id(@sheet)}", partial: 'sheets/sheet', locals: { sheet: @sheet })
    end
  end
end
