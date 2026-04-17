module Sheets
  class CompletionsController < ApplicationController
    include SheetScoped

    def create
      @sheet.complete!
      render turbo_stream: turbo_stream.replace("sheet_#{@sheet.id}", partial: 'sheets/sheet', locals: { sheet: @sheet, pulse: true })
    end

    def destroy
      @sheet.uncomplete!
      render turbo_stream: turbo_stream.replace("sheet_#{@sheet.id}", partial: 'sheets/sheet', locals: { sheet: @sheet, pulse: true })
    end
  end
end
