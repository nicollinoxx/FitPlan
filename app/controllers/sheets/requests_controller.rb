module Sheets
  class RequestsController < ApplicationController
    include Scrollable

    before_action :set_user
    before_action :set_request, only: %i[accept destroy]

    def index
      requests = @user.sheet_requests_by_filter(params[:filter]).includes(:sender, :recipient, :sheet)
      scrollable_to requests
    end

    def new
      @sheets = @user.sheets
      scrollable_to friends.includes(avatar_attachment: :blob)
    end

    def create
      @recipient = @user.friends.find_by!(handle: params[:handle])

      SheetRequest.create_for_sheets(sender: @user, recipient: @recipient, sheet_ids: params[:sheet_ids])
      recede_or_redirect_to requests_path(filter: "sent"), notice: I18n.t("notice.sheet_request.create")
    end

    def accept
      @request.accepted!
      CopySheetJob.perform_later(@request)
    end

    def destroy
      @request&.destroy!
      render turbo_stream: turbo_stream.remove("sheet_request_#{params[:id]}")
    end

    private

    def set_user
      @user = Current.user
    end

    def friends
      params[:query].present? ? @user.friends.search_users(params[:query]) : @user.friends
    end

    def set_request
      @request = @user.received_sheet_requests.or(@user.sent_sheet_requests).find_by(id: params[:id])
    end
  end
end
