module SheetScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_sheet
  end

  private
    def set_sheet
      @sheet = Sheet.find(params[:sheet_id])
    end
end
