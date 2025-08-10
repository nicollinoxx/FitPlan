class SheetRequestsController < ApplicationController
  before_action :set_user
  before_action :set_recipient, only: %i[new create]
  before_action :set_sheet_request, only: %i[accept destroy]

  def index
    @sheet_requests = SheetRequest.filtered_by(@user, params[:filter])

    set_page_and_extract_portion_from @sheet_requests
    sleep 2.seconds unless @page.first?
  end

  def new
    @sheets = @user.sheets
  end

  def create
    sheet_ids = params[:sheet_ids] || []

    SheetRequest.transaction do
      sheet_ids.each do |sheet_id|
        SheetRequest.create!(sender: @user, recipient: @recipient, sheet_id: sheet_id, status: "pending")
      end
    end

    refresh_or_redirect_to sheet_requests_path(filter: "sent"), notice: I18n.t('notice.sheet_request.create')
  end

  def accept
    return unless @sheet_request.receiver?

    @sheet_request.update!(status: "accepted")
    CopySheetJob.perform_later(@sheet_request.recipient, @sheet_request.sheet)
  end

  def destroy
    return unless @sheet_request.sender? || @sheet_request.receiver?

    @sheet_request.destroy!
    render turbo_stream: turbo_stream.remove("sheet_request_#{@sheet_request.id}")
  end

  private

  def set_user
    @user = Current.user
  end

  def set_recipient
    @recipient = User.find_by(handle: params[:handle]) if params[:handle].present?
  end

  def set_sheet_request
    @sheet_request = SheetRequest.find(params[:id])
  end
end
