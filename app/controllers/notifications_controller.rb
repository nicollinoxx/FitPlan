class NotificationsController < ApplicationController
  before_action :set_user
  before_action :set_notification, only: %i[ accept destroy ]

  def index
    @notifications = @user.received_notifications
  end

  def create
    recipient = User.find(params[:recipient_id])
    sheet = Sheet.find(params[:sheet_id])
    @notification = sheet.notifications.build(sender: Current.user, recipient: recipient, message: "Want to send a copy of the type sheet #{sheet.sheet_type}")

    if @notification.save
      refresh_or_redirect_to sheet, notice: "Notification copy sheet sent"
    end
  end

  def accept
    if @notification.update(accepted: true)
      @notification.sheet.accept_notification(@notification.recipient_id)

      refresh_or_redirect_to notifications_path, notice: "Notificação aceita com sucesso!"
    end
  end

  def destroy
    @notification.destroy
  end

  private

  def set_user
    @user = Current.user
  end

  def set_notification
    @notification = @user.received_notifications.find(params[:id])
  end
end
