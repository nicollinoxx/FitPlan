class Shares::SharedSheetsController < ApplicationController
  before_action :set_user
  before_action :set_recipient, only: %i[ new create ]
  before_action :set_shared_sheet, only: %i[ accept destroy ]

  def index
    @shared_sheets = @user.received_shared_sheets
  end

  def new
    @sheets = @user.sheets
    @shared_sheet = @user.sent_shared_sheets.build(recipient: @recipient)
  end

  def create
    sheets = Array(params[:sheets])

    unless sheets.empty?
      shared_sheets = sheets.map do |sheet_id|
        @user.sent_shared_sheets.build(recipient: @recipient, sheet_id: sheet_id)
      end

      redirect_to shares_shared_sheets_path, notice: "Fichas compartilhadas com sucesso!" if shared_sheets.all?(&:save)
    end
  end

  def accept
    sheet = @shared_sheet.sheet
    recipient = @shared_sheet.recipient

    CopySheetJob.perform_later(recipient, sheet) if @shared_sheet.update(status: 'accepted')
  end

  def destroy
    @shared_sheet.destroy
    render turbo_stream: turbo_stream.remove("shared_sheet_#{@shared_sheet.id}")
  end

  private

    def set_recipient
      @recipient = User.find_by(handle: params[:handle]) if params[:handle].present?
    end

    def set_shared_sheet
      @shared_sheet = @user.received_shared_sheets.find(params[:id])
    end

    def set_user
      @user = Current.user
    end
end
