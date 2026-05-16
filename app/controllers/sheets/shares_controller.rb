class Sheets::SharesController < ApplicationController
  before_action :set_user

  def index
    set_page_and_extract_portion_from @user.sheet_shares_by_filter(params[:filter])
  end

  def show
    @share = SheetShare.accessible_by(@user).with_associations.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    recede_or_redirect_to sheets_shares_path(filter: params[:filter])
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

  def destroy
    SheetShare.accessible_by(@user).find(params[:id]).destroy!
    recede_or_redirect_to sheets_shares_path(filter: params[:filter], format: :html), notice: t("notice.sheet_share.destroy")
  end

  private

    def set_user
      @user = Current.user
    end

    def friends
      params[:query].present? ? @user.friends.search_users(params[:query]) : @user.friends
    end
end
