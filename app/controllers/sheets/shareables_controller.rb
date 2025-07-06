class Sheets::ShareablesController < ApplicationController
  include SheetScoped

  def index
    @users = User.search_by_name(params[:name], Current.user.id) if params[:name].present?
  end

  def create
    @recipient = User.find_by(username: params[:recipient_name])
    @notification = @sheet.notifications.build(sender: Current.user, recipient: @recipient, message: "Want to send a copy sheet (#{@sheet.name})")

    unless @notification.save
      refresh_or_redirect_to sheet_shareables_path(@sheet), notice: "#{@notification.errors.full_messages.to_sentence}"
    end
  end
end
