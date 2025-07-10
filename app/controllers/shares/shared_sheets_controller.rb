class Shares::SharedSheetsController < ApplicationController
  before_action :set_user
  before_action :set_shared_sheet, only: %i[ accept destroy ]

  def index
    @shared_sheets = @user.received_shared_sheets
  end

  def new
    @recipient = User.find_by(handle: params[:handle]) if params[:handle].present?
    @sheets = @user.sheets
    @shared_sheet = @user.sent_shared_sheets.build(recipient: @recipient)
  end

  def create
    recipient = User.find_by(handle: params[:handle])
    sheet_ids = Array(params[:sheet_ids]).reject(&:blank?)

    shared_sheets = sheet_ids.map do |sheet_id|
      @user.sent_shared_sheets.build(recipient: recipient, sheet_id: sheet_id)
    end

    if shared_sheets.all?(&:save)
      redirect_to shares_shared_sheets_path, notice: "Fichas compartilhadas com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def accept
    sheet_id = @shared_sheet.sheet_id
    recipient_id = @shared_sheet.recipient_id

    CopySheetJob.perform_later(recipient_id, sheet_id) if @shared_sheet.update(status: 'accepted')
  end

  def destroy
    @shared_sheet.destroy
    render turbo_stream: turbo_stream.remove("shared_sheet_#{@shared_sheet.id}")
  end

  private

  def set_shared_sheet
    @shared_sheet = @user.received_shared_sheets.find(params[:id])
  end

  def set_user
    @user = Current.user
  end
end
