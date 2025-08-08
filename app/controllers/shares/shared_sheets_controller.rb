class Shares::SharedSheetsController < ApplicationController
  before_action :set_user
  before_action :set_recipient, only: %i[ new create ]
  before_action :set_shared_sheet, only: %i[ accept destroy ]

  def index
    @shared_sheets = SharedSheet.filtered_by(@user, params[:filter])
  end

  def new
    @sheets = @user.sheets
  end

  def create
    sheet_ids = params[:sheet_ids]

    ActiveRecord::Base.transaction do
      sheet_ids.each do |sheet_id|
        @user.sent_shared_sheets.create!(recipient: @recipient, sheet_id: sheet_id, status: "pending")
      end
    end

    redirect_to shares_shared_sheets_path(filter: "sent"), notice: "Fichas compartilhadas com sucesso!"
  end

  def accept
    return unless @shared_sheet.receiver?

    @shared_sheet.update!(status: 'accepted')
    CopySheetJob.perform_later(@shared_sheet.recipient, @shared_sheet.sheet)
  end

  def destroy
    return unless @shared_sheet.receiver? || @shared_sheet.owner?

    @shared_sheet.destroy!
    render turbo_stream: turbo_stream.remove("shared_sheet_#{@shared_sheet.id}")
  end

  private

    def set_recipient
      @recipient = User.find_by(handle: params[:handle]) if params[:handle].present?
    end

    def set_shared_sheet
      @shared_sheet = @user.received_shared_sheets.find(params[:id])
      rescue ActiveRecord::RecordNotFound

      @shared_sheet = @user.sent_shared_sheets.find(params[:id])
    end

    def set_user
      @user = Current.user
    end
end
