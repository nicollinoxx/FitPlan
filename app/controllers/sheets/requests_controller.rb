module Sheets
  class RequestsController < ApplicationController
    before_action :set_user
    before_action :set_recipient, only: %i[new create]
    before_action :set_request, only: %i[accept destroy]

    def index
      @requests = @user.sheet_requests_by_filter(params[:filter]).includes(:sender, :recipient, :sheet)

      set_page_and_extract_portion_from @requests
      sleep 2.seconds unless @page.first?
    end

    def new
      @sheets = @user.sheets.authored.shareable
    end

    def create
      SheetRequest.create_for_sheets(sender: @user, recipient: @recipient, sheet_ids: sheet_ids)
      recede_or_redirect_to requests_path(filter: "sent"), notice: I18n.t("notice.sheet_request.create")
    end

    def accept
      @request.accepted!
      CopySheetJob.perform_later(@request)
    end

    def destroy
      @request.destroy!
      render turbo_stream: turbo_stream.remove("sheet_request_#{@request.id}")
    end

    private

    def set_user
      @user = Current.user
    end

    def sheet_ids
      Array(params[:sheet_ids]).map(&:to_i).uniq
    end

    def set_recipient
      @recipient = User.find_by(handle: params[:handle])
    end

    def set_request
      @request = @user.received_sheet_requests.or(@user.sent_sheet_requests).find(params[:id])
    end
  end
end
