class Sheets::SharesController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_user

  def index
    sheet_shares = @user.sheet_shares_by_filter(params[:filter]).includes(:sender, :recipient, sheet_requests: :sheet)
    set_page_and_extract_portion_from sheet_shares
  end

  def show
    @share = SheetShare.accessible_by(@user).includes(:sender, :recipient, sheet_requests: :sheet).find(params[:id])

    rescue ActiveRecord::RecordNotFound
      redirect_to sheets_shares_path(params[:filter]), alert: t("alert.sheet_share.not_found")
  end

  def new
    @sheets = @user.sheets
    set_page_and_extract_portion_from friends.includes(avatar_attachment: :blob)
  end

  def create
    @recipient = @user.friends.find_by!(handle: params[:handle])

    SheetShare.create_with_requests(sender: @user, recipient: @recipient, sheet_ids: params[:sheet_ids])
    recede_or_redirect_to sheets_shares_path(filter: "sent"), notice: t("notice.sheet_request.create")
  end

  def destroy
    SheetShare.accessible_by(@user).find(params[:id]).destroy!
    recede_or_redirect_to sheets_shares_path(format: :html, filter: params[:filter])
  end

  private

    def set_user
      @user = Current.user
    end

    def friends
      params[:query].present? ? @user.friends.search_users(params[:query]) : @user.friends
    end
end
