module Sheets
  class CompletionsController < ApplicationController
    include SheetScoped
    include ActionView::RecordIdentifier

    def create
      @sheet.complete!
      render turbo_stream: turbo_stream.replace("#{dom_id(@sheet)}_card", partial: 'sheets/sheet', locals: { sheet: @sheet })
    end

    def destroy
      @sheet.uncomplete!
      render turbo_stream: turbo_stream.replace("#{dom_id(@sheet)}_card", partial: 'sheets/sheet', locals: { sheet: @sheet })
    end
  end
end
