class NotificationsController < ApplicationController
  before_action :set_user
  before_action :set_notification, only: %i[ accept destroy ]

  def index
    @notifications = @user.received_notifications
  end

  def accept
    @notification.sheet.accept_notification(@notification.recipient_id) if @notification.update(accepted: true)
  end

  def destroy
    @notification.destroy
    render turbo_stream: turbo_stream.remove("notification_#{@notification.id}")
  end

  private

  def set_user
    @user = Current.user
  end

  def set_notification
    @notification = @user.received_notifications.find(params[:id])
  end
end
