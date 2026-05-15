class Sheets::SharesController < ApplicationController
  before_action :set_user

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def index
    sheet_shares = @user.sheet_shares_by_filter(params[:filter]).includes(:sender, :recipient, sheet_requests: :sheet)
    set_page_and_extract_portion_from sheet_shares
  end

  def show
    @share = SheetShare.accessible_by(@user).includes(:sender, :recipient, sheet_requests: :sheet).find(params[:id])
  end

  def new
    @sheets = @user.sheets.with_content
    set_page_and_extract_portion_from friends.includes(avatar_attachment: :blob)
  end

  def create
    @recipient = @user.friends.find_by!(handle: params[:handle])

    SheetShare.create_with_requests(sender: @user, recipient: @recipient, sheet_ids: params[:sheet_ids])
    recede_or_redirect_to sheets_shares_path(filter: "sent"), notice: t("notice.sheet_request.create")
  end

  private

    def not_found
      redirect_to sheets_shares_path(filter: params[:filter]), alert: t("alert.sheet_share.not_found")
    end

    def set_user
      @user = Current.user
    end

    def friends
      params[:query].present? ? @user.friends.search_users(params[:query]) : @user.friends
    end
end
