class Sheets::ShareablesController < ApplicationController
  include SheetScoped

  def index
    @user = User.find_by(handle: params[:handle]) if params[:handle].present?
  end

  def create
    @recipient = User.find_by(username: params[:recipient_name])
    @notification = @sheet.notifications.build(sender: Current.user, recipient: @recipient, message: "Want to send a copy sheet (#{@sheet.name})")

    unless @notification.save
      refresh_or_redirect_to sheet_shareables_path(@sheet), notice: "#{@notification.errors.full_messages.to_sentence}"
    end
  end
end
