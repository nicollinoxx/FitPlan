module SheetScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_sheet
  end

  private

    def set_sheet
      @sheet = Current.user.sheets.find(params.expect(:sheet_id))
    end
end
